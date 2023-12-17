class_name DualPurposeWeapon extends Weapon


# engine/weapons/DualPurposeWeapon -- fusion, AR, alien gun


# TO DO: BUG: AR auto-reloading doesn't work when one trigger is empty and ammo for it is picked up while the other trigger is firing; need to override the default Weapon.inventory_increased method to handle these cases as well


var __triggers_shoot_independently: bool # true for AR; false for fusion and alien gun

var __primary_is_shooting   := false # used if triggers are independent # TO DO: can we get rid of these and use CAN_SHOOT_[SECONDARY/PRIMARY] instead? we'd need to add a SHOOTING_BOTH state as well
var __secondary_is_shooting := false


# initialization

func configure(weapon_data: Dictionary) -> void:
	super.configure(weapon_data)
	__triggers_shoot_independently  = weapon_data.triggers_shoot_independently
	assert(self.__weapon_item.max_count == 1)
	assert(self.__weapon_item.count in [0, 1])


# FSM

func __set_state(next_state: State) -> void:
	assert(next_state != self.state) # we could ignore non-transition transitions, better to catch them during testing as they're likely due to bad implementation
	var previous_state = self.state
	#print("__set_state: ", debug_status, "  ", self.name_for_state(previous_state), " -> ", self.name_for_state(next_state))
	super.__set_state(next_state)
	# important: this switch and the function calls inside it must not call __set_state, directly or indirectly; transitional states, e.g. ACTIVATED, should set next_state to the state they want to transition to
	match next_state:
		Weapon.State.ACTIVATING:
			self.__connect()
			self.__activating()
			WeaponManager.weapon_timer.start(self.__weapon_data.activating_time)
		
		Weapon.State.ACTIVATED:
			WeaponManager.weapon_timer.stop() # cancel the activation timer if weapon was activated instantly
			self.__activated()
			next_state = Weapon.State.IDLE
		
		Weapon.State.IDLE:
			# reloading is exclusive: both triggers must finish firing before one can be reloaded and then, optionally, the other
			if self.primary_needs_reload():
				# TO DO: implement __weapon_data.disappears_when_empty
				if self.primary_magazine.try_to_refill():
					next_state = Weapon.State.RELOADING_PRIMARY
				elif self.secondary_needs_reload():
					if self.secondary_magazine.try_to_refill():
						next_state = Weapon.State.RELOADING_SECONDARY 
					else:
						if not __primary_is_shooting and not __secondary_is_shooting:
							next_state = Weapon.State.EMPTY
			elif self.secondary_needs_reload():
				# TO DO: implement __weapon_data.disappears_when_empty
				if self.secondary_magazine.try_to_refill():
					next_state = Weapon.State.RELOADING_SECONDARY
		
		Weapon.State.RELOADING_PRIMARY:
			self.__reloading_primary()
			WeaponManager.weapon_timer.start(self.__primary_trigger_data.reloading_time)
		
		Weapon.State.RELOADING_SECONDARY:
			self.__reloading_secondary()
			WeaponManager.weapon_timer.start(self.__secondary_trigger_data.reloading_time)
		
		# TO DO: if there is insufficient ammo to fire either trigger, currently there's no way to empty the magazine so the weapon reloads (note: this isn't an issue for MCR as the only weapon that can report "insufficient ammo" is fusion's secondary trigger - and its magazine can *always* be emptied since the primary trigger consumes 1 round per-shot); eventually we should handle this condition and perform a reload, discarding whatever was left in the magazine
		Weapon.State.SHOOTING_PRIMARY:
			if not __primary_is_shooting and self.primary_magazine.try_to_consume(self.__primary_trigger_data.rounds_per_shot):
				__primary_is_shooting = true
				self.__shooting_primary()
				WeaponManager.primary_timer.start(self.__primary_trigger_data.shooting_time)
			else:
				__primary_is_shooting = true
				next_state = Weapon.State.SHOOTING_PRIMARY_FAILED # primary failed to fire
		
		Weapon.State.SHOOTING_SECONDARY:
			if not __secondary_is_shooting and self.secondary_magazine.try_to_consume(self.__secondary_trigger_data.rounds_per_shot):
				__secondary_is_shooting = true
				self.__shooting_secondary()
				WeaponManager.secondary_timer.start(self.__secondary_trigger_data.shooting_time)
			else:
				__secondary_is_shooting = true
				next_state = Weapon.State.SHOOTING_SECONDARY_FAILED
		
		Weapon.State.SHOOTING_PRIMARY_ENDED:
			__primary_is_shooting = false
			if __secondary_is_shooting:
				pass # next_state = Weapon.State.SHOOTING_SECONDARY # causes stack overflow; can't do anything here unless we add an extra SHOOTING_ANY state which we can safely transition to
			else:
				next_state = Weapon.State.IDLE
		
		Weapon.State.SHOOTING_SECONDARY_ENDED:
			__secondary_is_shooting = false
			if __primary_is_shooting:
				pass
			else:
				next_state = Weapon.State.IDLE
		
		Weapon.State.SHOOTING_PRIMARY_FAILED:
			__primary_is_shooting = false
			self.__shooting_primary_failed()
			WeaponManager.weapon_timer.start(self.__primary_trigger_data.empty_time)
		
		Weapon.State.SHOOTING_SECONDARY_FAILED:
			__secondary_is_shooting = false
			self.__shooting_secondary_failed()
			WeaponManager.weapon_timer.start(self.__secondary_trigger_data.empty_time)
		
		Weapon.State.EMPTY:
			assert(previous_state != Weapon.State.DEACTIVATING)
			# both triggers are empty so tell WeaponManager to deactivate this weapon
			WeaponManager.current_weapon_emptied.call_deferred(self) # important: WeaponManager must be notified *after* __set_state has returned
		
		Weapon.State.DEACTIVATING:
			self.__deactivating()
			WeaponManager.weapon_timer.start(self.__weapon_data.deactivating_time)
			#print("DEACTIVATING ", WeaponManager.weapon_timer)
		
		Weapon.State.DEACTIVATED:
			self.__deactivated()
			self.__disconnect()
			# TO DO: support weapon_data.disappears_after_use; change it to disappears_when_empty, possibly moving this flag to trigger data, which allows for optional ammo reloads
	WeaponManager.weapon_activity_changed.emit(self)
	# transitional states can immediately transition to next state
	#print("checking if next state:  prev=", self.name_for_state(previous_state), "  current=", self.name_for_state(self.state), "  next=", self.name_for_state(next_state))
	
	if previous_state == Weapon.State.DEACTIVATING:
		assert(next_state == Weapon.State.DEACTIVATED)
	if next_state != self.state:
		self.__set_state(next_state) # TO DO: should this be call_deferred?


func __weapon_timer_ended() -> void:
	#print("GOTO from ", self.debug_state, "  ")
	match self.state:
		Weapon.State.ACTIVATING:
			self.__set_state(Weapon.State.ACTIVATED)
		
		Weapon.State.DEACTIVATING:
			self.__set_state(Weapon.State.DEACTIVATED)
		
		Weapon.State.RELOADING_PRIMARY, Weapon.State.RELOADING_SECONDARY:
			self.__set_state(Weapon.State.IDLE) # if reloaded primary, IDLE will check if secondary needs reloading
		
		
		# DEBUG: check if there's any other states that might slip through
		
		# TO DO: what's correct behavior for this line?
		Weapon.State.SHOOTING_PRIMARY_FAILED, Weapon.State.SHOOTING_SECONDARY_FAILED:
			pass
			#__set_state(Weapon.State.IDLE) # premature, as the other trigger may be shooting
		
		Weapon.State.SHOOTING_PRIMARY, Weapon.State.SHOOTING_SECONDARY:
			pass
		
		Weapon.State.SHOOTING_PRIMARY_ENDED, Weapon.State.SHOOTING_SECONDARY_ENDED:
			pass
		
		Weapon.State.EMPTY:
			pass
		_:
			assert(false, "Timed out but on unexpected %s" % self.debug_state)


func __primary_timer_ended() -> void:
	self.__set_state(Weapon.State.SHOOTING_PRIMARY_ENDED)

func __secondary_timer_ended() -> void:
	self.__set_state(Weapon.State.SHOOTING_SECONDARY_ENDED)


# TO DO: some/all of these functions can be inlined later; for now, they make __set_state easier to read

# activation

func __activating() -> void:
	self.__primary_hand.activating()


func __activated() -> void:
	self.__primary_hand.activated()
	self.__primary_hand.update_ammo(self.primary_magazine, self.secondary_magazine)


# reloading

func __reloading_primary() -> void:
	self.__primary_hand.reload()
	self.__primary_hand.update_ammo(self.primary_magazine, self.secondary_magazine)

func __reloading_secondary() -> void:
	self.__primary_hand.secondary_reload()
	self.__primary_hand.update_ammo(self.primary_magazine, self.secondary_magazine)


# shooting

func __shooting_primary() -> void:
	self.__primary_hand.shoot()
	self.__primary_hand.update_ammo(self.primary_magazine, self.secondary_magazine) # TO DO: premature; display shouldn't update until reloading is finished

func __shooting_secondary() -> void:
	self.__primary_hand.secondary_shoot()
	self.__primary_hand.update_ammo(self.primary_magazine, self.secondary_magazine) # TO DO: premature

func __shooting_primary_failed() -> void:
	self.__primary_hand.empty()

func __shooting_secondary_failed() -> void:
	self.__primary_hand.secondary_empty()


# deactivation

func __deactivating() -> void:
	self.__primary_hand.deactivating()


func __deactivated() -> void:
	self.__primary_hand.deactivated()


# Player shoots the weapon

func shoot(player: Player, is_primary: bool) -> void: # is_primary determines which hand shoots first
	
	# this is not the most elegant code :)
	
	if self.state == Weapon.State.IDLE:
		self.__set_state(Weapon.State.SHOOTING_PRIMARY if is_primary else Weapon.State.SHOOTING_SECONDARY)

	elif self.state > 10 and self.state < 40: # kludgy, but we don't want a trigger shooting outside of idle or the other trigger shooting
		if is_primary:
			if not __primary_is_shooting and (__triggers_shoot_independently or not __secondary_is_shooting):
				self.__set_state(Weapon.State.SHOOTING_PRIMARY)
			else:
				return
		else:
			if not __secondary_is_shooting and (__triggers_shoot_independently or not __primary_is_shooting):
				self.__set_state(Weapon.State.SHOOTING_SECONDARY)
			else:
				return
	else:
		return
	
	# confirm we should launch projectile
	match self.state:
		Weapon.State.SHOOTING_PRIMARY:
			self.spawn_primary_projectile(player)
		Weapon.State.SHOOTING_SECONDARY:
			self.spawn_secondary_projectile(player)

