class_name SinglePurposeWeapon extends Weapon


# engine/weapons/SinglePurposeWeapon.gd


# fist, flamethrower, rocket launcher, SMG


# initialization

func configure(weapon_data: Dictionary) -> void:
	#assert(weapon_data.secondary_trigger == null) # secondary_trigger definition is not normally used in single-purpose weapons, but FIST subclass uses secondary_trigger for sprint-punch trigger data
	super.configure(weapon_data)
	assert(self.weapon_item.max_count == 1)
	assert(self.weapon_item.count in [0, 1])


# weapon state

func __set_state(next_state: State) -> void:
	assert(next_state != self.state) # while we could ignore non-transition transitions, better to catch them during testing as they're likely due to some bad implementation somewhere
	var previous_state = self.state
	super.__set_state(next_state)
	
	match next_state:
		Weapon.State.ACTIVATING:
			self.__activating_primary()
			self.__set_next_transition(Weapon.State.ACTIVATED, self.__activating_time(previous_state))
		
		Weapon.State.ACTIVATED:
			self.__activated_primary()
			self.__set_next_transition(Weapon.State.IDLE)
		
		Weapon.State.IDLE:
			# immediately transition to reloading if needed, else remain at IDLE
			if self.primary_needs_reload():
				if self.primary_magazine.try_to_refill():
					self.__set_next_transition(Weapon.State.RELOADING_PRIMARY)
				else:
					# TO DO: implement __weapon_data.disappears_when_empty; or should that be done in Weapon base class or in WeaponManager?
					self.__set_next_transition(Weapon.State.EMPTY)
		
		Weapon.State.RELOADING_PRIMARY:
			self.__reloading_primary()
			self.__set_next_transition(Weapon.State.IDLE, self.__primary_trigger_data.reloading_time)
		
		Weapon.State.SHOOTING_PRIMARY:
			if self.primary_magazine.try_to_consume(self.__primary_trigger_data.rounds_per_shot):
				super.__set_state(Weapon.State.SHOOTING_PRIMARY_SUCCEEDED)
				self.__shooting_primary()
				self.__set_next_transition(Weapon.State.IDLE, self.__primary_trigger_data.shooting_time)
			else:
				super.__set_state(Weapon.State.SHOOTING_PRIMARY_FAILED)
				self.__shooting_primary_failed()
				self.__set_next_transition(Weapon.State.IDLE, self.__primary_trigger_data.empty_time)
		
		Weapon.State.EMPTY:
			# trigger[s] are empty so tell WeaponManager to deactivate this weapon
			WeaponManager.current_weapon_emptied.call_deferred(self) # important: WeaponManager must be notified *after* __set_state has returned; WM will call Weapon.deactivate so do not set a transition here
		
		Weapon.State.DEACTIVATING:
			self.__deactivating_primary()
			self.__set_next_transition(Weapon.State.DEACTIVATED, self.__deactivating_time(previous_state))
		
		Weapon.State.DEACTIVATED:
			self.__deactivated_primary()
			# DEACTIVATED is a stable state
	WeaponManager.weapon_activity_changed.emit(self)


# animation methods (whereas DualPurpose and DualWield have inlined these calls, the Fist subclass currently overrides these methods to display 2 alternating fists as 2 separate scenes; the 2 fists may eventually be combined into a single scene, allowing these to be inlined as well)

func __activating_primary() -> void:
	self.__primary_hand.activating()

func __activated_primary() -> void:
	self.__primary_hand.activated()


func __reloading_primary() -> void:
	self.__primary_hand.reload()


func __shooting_primary() -> void:
	self.__primary_hand.shoot()

func __shooting_primary_failed() -> void:
	self.__primary_hand.empty()


func __deactivating_primary() -> void:
	self.__primary_hand.deactivating()

func __deactivated_primary() -> void:
	self.__primary_hand.deactivated()


# Player shoots the weapon

func shoot(player: Player, is_primary: bool) -> void: # is_primary determines which hand shoots first
	if self.state == Weapon.State.IDLE:
		self.__set_state(Weapon.State.SHOOTING_PRIMARY)
		if self.state == Weapon.State.SHOOTING_PRIMARY_SUCCEEDED: # confirm projectile should be launched
			self.spawn_primary_projectile(player)




