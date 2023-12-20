class_name DualWieldWeapon extends Weapon


# engine/weapons/DualWieldWeapon.gd -- two single-purpose guns; the Player may have 0, 1, or 2 guns available at any time, so this class must be able to show/hide either hand or both hands as gun and ammo availability changes


# MCR: pistol, shotgun (TBC - M1 doesn't have it so don't bother implementing one-handed reload for now)
#
# (note: fist is a subclass of SinglePurposeWeapon: while the view displays two hands they operate as one weapon, firing at a constant rate)


# TO DO: reloading isn't right when it has run out of ammo then picks up 1 new mag, at which point it can be reactivated, then shortly after picks up another mag - this should activate and reload the 2nd pistol but appears to reload the 1st twice


# if one hand runs out of ammo # TO DO: think these do need to be State so they sync correctly when second gun is picked up; or may be better to wait till enabled hand is idle before
var __primary_enabled   := false
var __secondary_enabled := false

var __primary_needs_activating   := false
var __secondary_needs_activating := false


#var __triggers_reload_independently: bool # ignore this for now; not needed for MCR

var __can_dual_wield: bool # true if player has 2 guns; false if 1 or 0 guns
var __swaps_shooting_hand := false # hands swap automatically while either trigger key is held


# initialization

func configure(weapon_data: Dictionary) -> void:
	# assert(weapon_data.secondary_trigger == null) # primary_trigger definition is used for both guns
	super.configure(weapon_data)
	self.__secondary_trigger_data = weapon_data.primary_trigger
	assert(self.__weapon_item.max_count == 2)
	assert(self.__weapon_item.count in [0, 1, 2])
	__can_dual_wield = self.__weapon_item.count == 2
	#__triggers_reload_independently = weapon_data.triggers_reload_independently


# FSM

func __set_state(next_state: State) -> void:
	assert(next_state != self.state) # we could ignore non-transition transitions, better to catch them during testing as they're likely due to bad implementation
	var previous_state = self.state
	super.__set_state(next_state)
	# important: this switch and the function calls inside it must not call __set_state, directly or indirectly; transitional states, e.g. ACTIVATED, should set next_state to the state they want to transition to
	match next_state:
		Weapon.State.ACTIVATING:
			self.__connect()
			next_state = Weapon.State.REACTIVATING
		
		Weapon.State.ACTIVATED:
			WeaponManager.weapon_timer.stop() # cancel the activation timer if weapon was activated instantly
			if __primary_enabled:
				self.__activated_primary()
			if __secondary_enabled:
				self.__activated_secondary()
			next_state = Weapon.State.IDLE
		
		Weapon.State.REACTIVATING:
			if __primary_needs_activating:
				__primary_needs_activating = false
				__primary_enabled = true
				self.__activating_primary()
			if __secondary_needs_activating:
				__secondary_needs_activating = false
				__secondary_enabled = true
				self.__activating_secondary()
			WeaponManager.weapon_timer.start(self.__weapon_data.activating_time)
		
		Weapon.State.IDLE:
			if __primary_needs_activating or __secondary_needs_activating:
				next_state = Weapon.State.REACTIVATING
			elif self.primary_needs_reload():
				# TO DO: implement __weapon_data.disappears_when_empty
				if self.primary_magazine.try_to_refill():
					next_state = Weapon.State.RELOADING_PRIMARY
				elif self.secondary_needs_reload():
					next_state = Weapon.State.EMPTY
				else:
					self.__deactivating_primary()
			elif self.secondary_needs_reload():
				# TO DO: implement __weapon_data.disappears_when_empty
				if self.secondary_magazine.try_to_refill():
					next_state = Weapon.State.RELOADING_SECONDARY
				else:
					self.__deactivating_secondary()
		
		Weapon.State.RELOADING_PRIMARY:
			self.__reloading_primary()
			WeaponManager.weapon_timer.start(self.__primary_trigger_data.reloading_time)
		
		Weapon.State.RELOADING_SECONDARY:
			self.__reloading_secondary()
			WeaponManager.weapon_timer.start(self.__secondary_trigger_data.reloading_time)
		
		
		# TO DO: if there is inadequate ammo here, that's a config bug as there's no way to deplete using the other trigger
		Weapon.State.SHOOTING_PRIMARY:
			if self.primary_magazine.try_to_consume(self.__primary_trigger_data.rounds_per_shot):
				self.__shooting_primary()
				WeaponManager.weapon_timer.start(self.__primary_trigger_data.shooting_time / 2)
			else:
				next_state = Weapon.State.SHOOTING_PRIMARY_FAILED # primary failed to fire
		
		Weapon.State.SHOOTING_SECONDARY:
			if self.secondary_magazine.try_to_consume(self.__secondary_trigger_data.rounds_per_shot):
				self.__shooting_secondary()
				WeaponManager.weapon_timer.start(self.__secondary_trigger_data.shooting_time / 2)
			else:
				next_state = Weapon.State.SHOOTING_SECONDARY_FAILED
		
		#Weapon.State.SHOOTING_PRIMARY_ENDED:
		#	pass
		#Weapon.State.SHOOTING_SECONDARY_ENDED:
		#	pass
		
		Weapon.State.SHOOTING_PRIMARY_FAILED:
			self.__shooting_primary_failed()
			WeaponManager.weapon_timer.start(self.__primary_trigger_data.empty_time)
		
		Weapon.State.SHOOTING_SECONDARY_FAILED:
			self.__shooting_secondary_failed()
			WeaponManager.weapon_timer.start(self.__secondary_trigger_data.empty_time)
		
		Weapon.State.SYNCHRONIZE_SHOOTING:
			if __swaps_shooting_hand:
				if previous_state == Weapon.State.SHOOTING_PRIMARY:
					if __secondary_enabled and not self.secondary_needs_reload(): # should be finished by now
						next_state = Weapon.State.CAN_SHOOT_SECONDARY
				else:
					if __primary_enabled and not self.primary_needs_reload(): # should be finished by now
						next_state = Weapon.State.CAN_SHOOT_PRIMARY
			WeaponManager.weapon_timer.start(self.__primary_trigger_data.shooting_time / 2) # run the remaining time on the currently shooting hand
		
		Weapon.State.CAN_SHOOT_PRIMARY, Weapon.State.CAN_SHOOT_SECONDARY:
			pass
		
		Weapon.State.EMPTY:
			# both triggers are empty so tell WeaponManager to deactivate this weapon
			WeaponManager.current_weapon_emptied.call_deferred(self) # important: WeaponManager must be notified *after* __set_state has returned
		
		Weapon.State.DEACTIVATING:
			self.__deactivating_primary()
			self.__deactivating_secondary()
			WeaponManager.weapon_timer.start(self.__weapon_data.deactivating_time)
		
		Weapon.State.DEACTIVATED:
			self.__deactivated()
			self.__disconnect()
	WeaponManager.weapon_activity_changed.emit(self)
	# transitional states can immediately transition to next state
	if next_state != self.state:
		self.__set_state(next_state)


func __weapon_timer_ended() -> void:
	match self.state:
		Weapon.State.ACTIVATING:
			self.__set_state(Weapon.State.ACTIVATED)
		
		Weapon.State.DEACTIVATING:
			self.__set_state(Weapon.State.DEACTIVATED)
		
		Weapon.State.REACTIVATING:
			self.__set_state(Weapon.State.IDLE)
		
		Weapon.State.RELOADING_PRIMARY:
			__primary_enabled = true
			self.__set_state(Weapon.State.IDLE) # if reloaded primary, IDLE will check if secondary needs reloading
			
		Weapon.State.RELOADING_SECONDARY:
			__secondary_enabled = true
			self.__set_state(Weapon.State.IDLE) # if reloaded primary, IDLE will check if secondary needs reloading
		
		Weapon.State.SHOOTING_PRIMARY, Weapon.State.SHOOTING_SECONDARY:
			self.__set_state(Weapon.State.SYNCHRONIZE_SHOOTING)
		
		Weapon.State.SHOOTING_PRIMARY_FAILED, Weapon.State.SHOOTING_SECONDARY_FAILED:
			self.__set_state(Weapon.State.IDLE) # IDLE will try to reload one more time (in case ammo has just been picked up) then deactivate the empty trigger
		
		Weapon.State.CAN_SHOOT_PRIMARY, Weapon.State.CAN_SHOOT_SECONDARY: # other gun finished shooting and user has released firing key
			self.__set_state(Weapon.State.IDLE)
		
		Weapon.State.SYNCHRONIZE_SHOOTING: # both guns finished shooting
			self.__set_state(Weapon.State.IDLE)


func secondary_needs_reload() -> bool:
	return __can_dual_wield and self.secondary_magazine.count == 0


# animations # TO DO: these could be inlined but keeping them as separate functions makes __set_state easier to read

func __activating_primary() -> void:
	self.__primary_hand.activating()

func __activating_secondary() -> void:
	self.__secondary_hand.activating()


func __activated_primary() -> void:
	self.__primary_hand.activated()
	self.__primary_hand.update_ammo(self.primary_magazine, null)

func __activated_secondary() -> void:
	self.__secondary_hand.activated()
	self.__secondary_hand.update_ammo(self.secondary_magazine, null)

func __reloading_primary() -> void:
	self.__primary_hand.reload()
	self.__secondary_hand.reload_other()
	self.__primary_hand.update_ammo(self.primary_magazine, null) # TO DO: premature; display shouldn't update until reloading finished

func __reloading_secondary() -> void:
	self.__secondary_hand.reload()
	self.__primary_hand.reload_other()
	self.__secondary_hand.update_ammo(self.secondary_magazine, null) # TO DO: premature


func __shooting_primary() -> void:
	self.__primary_hand.shoot()
	self.__primary_hand.update_ammo(self.primary_magazine, null)

func __shooting_secondary() -> void:
	self.__secondary_hand.shoot()
	self.__secondary_hand.update_ammo(self.secondary_magazine, null)

func __shooting_primary_failed() -> void:
	self.__primary_hand.empty()

func __shooting_secondary_failed() -> void:
	self.__secondary_hand.empty()


func __deactivating_primary() -> void:
	__swaps_shooting_hand = false
	if __primary_enabled:
		__primary_enabled = false
		self.__primary_hand.deactivating()

func __deactivating_secondary() -> void:
	__swaps_shooting_hand = false
	if __secondary_enabled:
		__secondary_enabled = false
		self.__secondary_hand.deactivating()

func __deactivated() -> void:
	self.__primary_hand.deactivated()
	self.__secondary_hand.deactivated()



# signal notification from InventoryManager when any pickable is picked up

func inventory_increased(item: InventoryManager.InventoryItem) -> void: # sent by any InventoryItem when it increments/decrements (while InventoryItem instances could send their own inventory_item_changed signals, allowing a WeaponTrigger to listen for a specific pickable, pickups are sufficiently rare that it shouldn't affect performance to listen to them all and filter here)
	if item == self.__weapon_item and not __can_dual_wield: # picked up second weapon, so activate it now if currently IDLE or on next IDLE if busy
		__can_dual_wield = true
		__secondary_needs_activating = true
		if self.state == Weapon.State.IDLE:
			self.__set_state(Weapon.State.ACTIVATING) # for now, pause shooting primary while activating secondary; TO DO: check Classic, and if secondary can activate while primary is mid-shot, amend this
	elif item == self.primary_magazine.inventory_item:
		
		# reload now if needed (if busy, will reload if needed on next IDLE)
		print("picked up ammo on ", self.debug_status, "; needs reload: ", self.primary_needs_reload(), "/", self.secondary_needs_reload())
		
		if self.primary_needs_reload():
			if self.state == Weapon.State.IDLE:
				self.__set_state(Weapon.State.RELOADING_PRIMARY if __primary_enabled else Weapon.State.ACTIVATING)
			elif not __primary_enabled:
				__primary_needs_activating = true # primary will be reactivated once weapon has finished its current activity and returns to IDLE
		elif self.secondary_needs_reload():
			if self.state == Weapon.State.IDLE:
				self.__set_state(Weapon.State.RELOADING_SECONDARY if __secondary_enabled else Weapon.State.ACTIVATING)
			elif not __secondary_enabled:
				__secondary_needs_activating = true # secondary will be reactivated once weapon has finished its current activity and returns to IDLE


# WeaponManager activates and deactivates the weapon

func activate(instantly: bool = false) -> void: # instantly is true when loading from saved game file
	# don't deplete inventory until reloading animations; for now, only check if there's enough ammo to reload one or both and activate one or both hands accordingly
	var magazines_count = self.primary_magazine.inventory_item.count
	if self.primary_needs_reload():
		magazines_count -= 1
		__primary_needs_activating = magazines_count >= 0
	else:
		__primary_needs_activating = true
	if __can_dual_wield: # if player only has 1 gun, it is always primary
		if self.secondary_needs_reload():
			magazines_count -= 1
			__secondary_needs_activating = magazines_count >= 0
		else:
			__secondary_needs_activating = true
	else:
		__secondary_needs_activating = false
	# activate one or both hands
	super.activate(instantly)


# Player shoots the weapon

func shoot(player: Player, is_primary: bool) -> void: # is_primary determines which hand shoots first
	match self.state:
		Weapon.State.IDLE:
			__swaps_shooting_hand = __can_dual_wield and __primary_enabled and __secondary_enabled
			if __can_dual_wield:
				if is_primary:
					self.__set_state(Weapon.State.SHOOTING_PRIMARY if __primary_enabled else Weapon.State.SHOOTING_SECONDARY)
				else:
					self.__set_state(Weapon.State.SHOOTING_SECONDARY if __secondary_enabled else Weapon.State.SHOOTING_PRIMARY)
			else:
				self.__set_state(Weapon.State.SHOOTING_PRIMARY)
		
		# SYCHRONIZE_SHOOTING is called halfway through one hand's shooting sequence and will transition to CAN_SHOOT_PRIMARY/SECONDARY if both guns are available, giving the other hand opportunity to start shooting if the trigger key is held down, effectively doubling the Player's firing rate
		Weapon.State.CAN_SHOOT_PRIMARY:
			self.__set_state(Weapon.State.SHOOTING_PRIMARY)
		
		Weapon.State.CAN_SHOOT_SECONDARY:
			self.__set_state(Weapon.State.SHOOTING_SECONDARY)
			
		_: # can't fire ATM
			return
	
	# TO DO: this is a bit mucky since __set_state doesn't have access to Player, which is required to create the projectile, so after calling __set_state we must confirm the new state is SHOOTING_[TRIGGER] before launching Projectile here
	
	# __set_state(SHOOTING_[TRIGGER]) may transition to FAILED, so must confirm here before launching Projectile
	match self.state:
		Weapon.State.SHOOTING_PRIMARY:
			self.spawn_primary_projectile(player)
		Weapon.State.SHOOTING_SECONDARY:
			self.spawn_secondary_projectile(player)


func trigger_just_released(is_primary: bool) -> void:
	__swaps_shooting_hand = false


