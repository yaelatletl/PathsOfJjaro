class_name DualPurposeWeapon extends Weapon


# engine/weapons/DualPurposeWeapon -- fusion, AR, alien gun


var __triggers_shoot_independently: bool # true for AR; false for fusion and alien gun

var __primary_is_shooting   := false # used if triggers are independent
var __secondary_is_shooting := false


# initialization

func configure(weapon_data: Dictionary) -> void:
	super.configure(weapon_data)
	__triggers_shoot_independently  = weapon_data.triggers_shoot_independently
	assert(self.weapon_item.max_count == 1)
	assert(self.weapon_item.count in [0, 1])


# FSM

func __set_state(next_state: State) -> void:
	assert(next_state != self.state) # we could ignore non-transition transitions, better to catch them during testing as they're likely due to bad implementation
	var previous_state = self.state
	#print("__set_state: ", debug_status, "  ", self.name_for_state(previous_state), " -> ", self.name_for_state(next_state))
	super.__set_state(next_state)
	# important: this switch and the function calls inside it must not call __set_state, directly or indirectly; transitional states, e.g. ACTIVATED, should set next_state to the state they want to transition to
	match next_state:
		Weapon.State.ACTIVATING:
			self.__activating()
			self.__set_next_transition(Weapon.State.ACTIVATED, self.__activating_time(previous_state))
		
		Weapon.State.ACTIVATED:
			self.__activated()
			self.__set_next_transition(Weapon.State.IDLE)
		
		Weapon.State.IDLE:
			# note: reloading is exclusive: both triggers must finish firing before one can be reloaded and then, optionally, the other (while simultaneous reloading of both could be implemented if needed, MCR doesn’t need it as the only dual-purpose weapon with 2 magazines is the AR, and the player would require a third hand to reload both mags at once while holding the gun. Which would look very silly.)
			if self.primary_needs_reload():
				# TO DO: implement __weapon_data.disappears_when_empty
				if self.primary_magazine.try_to_refill():
					self.__set_next_transition(Weapon.State.RELOADING_PRIMARY)
				elif self.secondary_needs_reload():
					if self.secondary_magazine.try_to_refill():
						self.__set_next_transition(Weapon.State.RELOADING_SECONDARY)
					else:
						if not __primary_is_shooting and not __secondary_is_shooting:
							self.__set_next_transition(Weapon.State.EMPTY)
						# else wait for trigger[s] to stop shooting
			elif self.secondary_needs_reload():
				# TO DO: implement __weapon_data.disappears_when_empty
				if self.secondary_magazine.try_to_refill():
					self.__set_next_transition(Weapon.State.RELOADING_SECONDARY)
		
		Weapon.State.RELOADING_PRIMARY:
			self.__reloading_primary()
			self.__set_next_transition(Weapon.State.IDLE, self.__primary_trigger_data.reloading_time)
		
		Weapon.State.RELOADING_SECONDARY:
			self.__reloading_secondary()
			self.__set_next_transition(Weapon.State.IDLE, self.__secondary_trigger_data.reloading_time)
		
		Weapon.State.SHOOTING_PRIMARY:
			if not __primary_is_shooting and self.primary_magazine.try_to_consume(self.__primary_trigger_data.rounds_per_shot):
				super.__set_state(Weapon.State.SHOOTING_PRIMARY_SUCCEEDED)
				__primary_is_shooting = true
				self.__shooting_primary()
				WeaponManager.primary_timer.start(self.__primary_trigger_data.shooting_time)
			else:
				super.__set_state(Weapon.State.SHOOTING_PRIMARY_FAILED) # primary failed to fire
				__primary_is_shooting = false
				self.__shooting_primary_failed()
				WeaponManager.primary_timer.start(self.__primary_trigger_data.empty_time)
		
		Weapon.State.SHOOTING_SECONDARY:
			if not __secondary_is_shooting and self.secondary_magazine.try_to_consume(self.__secondary_trigger_data.rounds_per_shot):
				super.__set_state(Weapon.State.SHOOTING_SECONDARY_SUCCEEDED)
				__secondary_is_shooting = true
				self.__shooting_secondary()
				WeaponManager.secondary_timer.start(self.__secondary_trigger_data.shooting_time)
			else:
				super.__set_state(Weapon.State.SHOOTING_SECONDARY_FAILED)
				__secondary_is_shooting = false
				self.__shooting_secondary_failed()
				WeaponManager.secondary_timer.start(self.__secondary_trigger_data.empty_time)
		
		Weapon.State.EMPTY:
			assert(previous_state != Weapon.State.DEACTIVATING)
			# both triggers are empty so tell WeaponManager to deactivate this weapon
			WeaponManager.current_weapon_emptied.call_deferred(self) # important: WeaponManager must be notified *after* __set_state has returned
		
		Weapon.State.DEACTIVATING:
			self.__deactivating()
			self.__set_next_transition(Weapon.State.DEACTIVATED, self.__deactivating_time(previous_state))
		
		Weapon.State.DEACTIVATED:
			self.__deactivated()
			# TO DO: support weapon_data.disappears_after_use; change it to disappears_when_empty, possibly moving this flag to trigger data, which allows for optional ammo reloads
	WeaponManager.weapon_activity_changed.emit(self)



func __primary_timer_ended() -> void:
	if self.state >= Weapon.State.IDLE:
		__primary_is_shooting = false
		if not __secondary_is_shooting:
			self.__set_state(Weapon.State.IDLE)

func __secondary_timer_ended() -> void:
	if self.state >= Weapon.State.IDLE:
		__secondary_is_shooting = false
		if not __primary_is_shooting:
			self.__set_state(Weapon.State.IDLE)


# activation

func __activating() -> void:
	self.__primary_hand.activating()

func __activated() -> void:
	self.__primary_hand.activated()


func __reloading_primary() -> void:
	self.__primary_hand.reload()

func __reloading_secondary() -> void:
	self.__primary_hand.secondary_reload()

func __shooting_primary() -> void:
	self.__primary_hand.shoot()

func __shooting_secondary() -> void:
	self.__primary_hand.secondary_shoot()

func __shooting_primary_failed() -> void:
	self.__primary_hand.empty()

func __shooting_secondary_failed() -> void:
	self.__primary_hand.secondary_empty()


func __deactivating() -> void:
	self.__primary_hand.deactivating()

func __deactivated() -> void:
	self.__primary_hand.deactivated()


# Player shoots the weapon

func shoot(player: Player, is_primary: bool) -> void: # is_primary determines which hand shoots first
	# a trigger can only shoot while idle or, if triggers are independent, while the other trigger is shooting
	if self.state == Weapon.State.IDLE:
		self.__set_state(Weapon.State.SHOOTING_PRIMARY if is_primary else Weapon.State.SHOOTING_SECONDARY)
	
	elif self.state  > Weapon.State.IDLE:
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
	
	match self.state: # confirm projectile should be launched
		Weapon.State.SHOOTING_PRIMARY_SUCCEEDED:
			self.spawn_primary_projectile(player)
		Weapon.State.SHOOTING_SECONDARY_SUCCEEDED:
			self.spawn_secondary_projectile(player)

