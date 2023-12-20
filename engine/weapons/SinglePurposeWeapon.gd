class_name SinglePurposeWeapon extends Weapon


# engine/weapons/SinglePurposeWeapon.gd


# fist, flamethrower, rocket launcher, SMG


# initialization

func configure(weapon_data: Dictionary) -> void:
	#assert(weapon_data.secondary_trigger == null) # secondary_trigger definition is not normally used in single-purpose weapons, but FIST subclass uses secondary_trigger for sprint-punch trigger data
	super.configure(weapon_data)
	assert(self.__weapon_item.max_count == 1)
	assert(self.__weapon_item.count in [0, 1])


# weapon state

func __set_state(next_state: State) -> void:
	assert(next_state != self.state) # while we could ignore non-transition transitions, better to catch them during testing as they're likely due to some bad implementation somewhere
	var previous_state = self.state
	super.__set_state(next_state)
	
	# important: this switch and the function calls inside it must not call __set_state, directly or indirectly; transitional states, e.g. ACTIVATED, should set next_state to the state they want to transition to
	match next_state:
		Weapon.State.ACTIVATING:
			self.__connect()
			self.__activating_primary()
			WeaponManager.weapon_timer.start(self.__weapon_data.activating_time)
		
		Weapon.State.ACTIVATED:
			WeaponManager.weapon_timer.stop() # cancel the activation timer if weapon was activated instantly
			self.__activated_primary()
			next_state = Weapon.State.IDLE
		
		Weapon.State.IDLE:
			if self.primary_needs_reload():
				if self.primary_magazine.try_to_refill():
					next_state = Weapon.State.RELOADING_PRIMARY
				else:
					# TO DO: implement __weapon_data.disappears_when_empty
					next_state = Weapon.State.EMPTY
		
		Weapon.State.RELOADING_PRIMARY:
			self.__reloading_primary()
			WeaponManager.weapon_timer.start(self.__primary_trigger_data.reloading_time)
		
		
		# TO DO: if there is inadequate ammo here, that's a config bug as there's no way to deplete using the other trigger
		Weapon.State.SHOOTING_PRIMARY:
			if self.primary_magazine.try_to_consume(self.__primary_trigger_data.rounds_per_shot):
				self.__shooting_primary()
				WeaponManager.weapon_timer.start(self.__primary_trigger_data.shooting_time)
			else:
				next_state = Weapon.State.SHOOTING_PRIMARY_FAILED # primary failed to fire
		
		#Weapon.State.SHOOTING_PRIMARY_ENDED:
		#	pass
		
		Weapon.State.SHOOTING_PRIMARY_FAILED:
			self.__shooting_primary_failed()
			WeaponManager.weapon_timer.start(self.__primary_trigger_data.empty_time)
		
		Weapon.State.EMPTY:
			# both triggers are empty so tell WeaponManager to deactivate this weapon
			WeaponManager.current_weapon_emptied.call_deferred(self) # important: WeaponManager must be notified *after* __set_state has returned
		
		Weapon.State.DEACTIVATING:
			self.__deactivating_primary()
			WeaponManager.weapon_timer.start(self.__weapon_data.deactivating_time)
		
		Weapon.State.DEACTIVATED:
			self.__deactivated_primary()
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
		
		Weapon.State.RELOADING_PRIMARY:
			self.__set_state(Weapon.State.IDLE)
		
		Weapon.State.SHOOTING_PRIMARY:
			self.__set_state(Weapon.State.IDLE)
		
		Weapon.State.SHOOTING_PRIMARY_FAILED:
			self.__set_state(Weapon.State.IDLE) # IDLE will try to reload one more time (in case ammo has just been picked up) then deactivate the empty trigger
		
		Weapon.State.SYNCHRONIZE_SHOOTING: # both guns finished shooting
			self.__set_state(Weapon.State.IDLE)


# animations

func __activating_primary() -> void:
	self.__primary_hand.activating()

func __activated_primary() -> void:
	self.__primary_hand.activated()
	self.__primary_hand.update_ammo(self.primary_magazine, null)


func __reloading_primary() -> void:
	self.__primary_hand.reload()
	self.__primary_hand.update_ammo(self.primary_magazine, null)


func __shooting_primary() -> void:
	self.__primary_hand.shoot()
	self.__primary_hand.update_ammo(self.primary_magazine, null) # TO DO: premature; display shouldn't update until reloading is finished

func __shooting_primary_failed() -> void:
	self.__primary_hand.empty()


func __deactivating_primary() -> void:
	self.__primary_hand.deactivating()

func __deactivated_primary() -> void:
	self.__primary_hand.deactivated()



# signal notification from InventoryManager when any pickable is picked up

#func inventory_increased(item: InventoryManager.InventoryItem) -> void: # sent by any InventoryItem when it increments/decrements (while InventoryItem instances could send their own inventory_item_changed signals, allowing a WeaponTrigger to listen for a specific pickable, pickups are sufficiently rare that it shouldn't affect performance to listen to them all and filter here)
#	if self.state == Weapon.State.IDLE and item == self.primary_magazine.inventory_item and self.primary_needs_reload():
#		__set_state(Weapon.State.RELOADING_PRIMARY)


# Player shoots the weapon

func shoot(player: Player, is_primary: bool) -> void: # is_primary determines which hand shoots first
	if self.state == Weapon.State.IDLE:
		self.__set_state(Weapon.State.SHOOTING_PRIMARY)
		# confirm we should launch the projectile
		if self.state == Weapon.State.SHOOTING_PRIMARY:
			self.spawn_primary_projectile(player)




