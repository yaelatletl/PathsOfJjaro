class_name DualPurposeWeapon extends Weapon


# engine/weapons/DualPurposeWeapon -- fusion, AR, alien gun


# TODO: should AR have better accuracy in single-shot? (burst shots should be as inaccurate as Classic)


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
			self.__primary_hand.activating()
			self.__set_next_transition(Weapon.State.ACTIVATED, self.__activating_time(previous_state))
		
		Weapon.State.ACTIVATED:
			if self.primary_magazine.is_available:
				self.__primary_trigger = TriggerState.NEEDS_RELOADING if self.primary_magazine.count == 0 else TriggerState.IDLE
			else:
				self.__primary_trigger = TriggerState.DISABLED
			if self.secondary_magazine.is_available:
				self.__secondary_trigger = TriggerState.NEEDS_RELOADING if self.secondary_magazine.count == 0 else TriggerState.IDLE
			else:
				self.__secondary_trigger = TriggerState.DISABLED
			self.__primary_hand.activated()
			self.__set_next_transition(Weapon.State.IDLE)
		
		Weapon.State.IDLE:
			# note: reloading is exclusive: both triggers must finish firing before one can be reloaded and then, optionally, the other (while simultaneous reloading of both could be implemented if needed, MCR doesn’t need it as the only dual-purpose weapon with 2 magazines is the AR, and the player would require a third hand to reload both mags at once while holding the gun. Which would look very silly.)
			if self.__primary_trigger == TriggerState.NEEDS_RELOADING:
				self.__set_next_transition(Weapon.State.RELOADING_PRIMARY)
			elif self.__secondary_trigger == TriggerState.NEEDS_RELOADING:
				self.__set_next_transition(Weapon.State.RELOADING_SECONDARY)
		
		Weapon.State.RELOADING_PRIMARY:
			if self.primary_magazine.try_to_refill():
				self.__primary_hand.reload()
				self.__set_next_transition(Weapon.State.RELOADING_PRIMARY_ENDED, self.__primary_trigger_data.reloading_time)
			else:
				self.__primary_trigger = TriggerState.DISABLED
				self.__set_next_transition(Weapon.State.EMPTY if self.__secondary_trigger == TriggerState.DISABLED else Weapon.State.IDLE)
		
		Weapon.State.RELOADING_SECONDARY:
			if self.secondary_magazine.try_to_refill():
				self.__primary_hand.secondary_reload()
				self.__set_next_transition(Weapon.State.RELOADING_SECONDARY_ENDED, self.__secondary_trigger_data.reloading_time)
			else:
				self.__secondary_trigger = TriggerState.DISABLED
				self.__set_next_transition(Weapon.State.EMPTY if self.__primary_trigger == TriggerState.DISABLED else Weapon.State.IDLE)
		
		Weapon.State.RELOADING_PRIMARY_ENDED:
			self.__primary_trigger = TriggerState.IDLE
			self.__set_next_transition(Weapon.State.IDLE)
		
		Weapon.State.RELOADING_SECONDARY_ENDED:
			self.__secondary_trigger = TriggerState.IDLE
			self.__set_next_transition(Weapon.State.IDLE)
		
		Weapon.State.SHOOTING_PRIMARY:
			if self.primary_magazine.try_to_consume(self.__primary_trigger_data.rounds_per_shot):
				super.__set_state(Weapon.State.SHOOTING_PRIMARY_SUCCEEDED)
				self.__primary_trigger = TriggerState.SHOOTING
				self.__primary_hand.shoot()
				WeaponManager.primary_timer.start(self.__primary_trigger_data.shooting_time)
			else:
				super.__set_state(Weapon.State.SHOOTING_PRIMARY_FAILED) # primary failed to fire
				self.__primary_trigger = TriggerState.NEEDS_RELOADING
				self.__primary_hand.empty()
				WeaponManager.primary_timer.start(self.__primary_trigger_data.empty_time)
		
		Weapon.State.SHOOTING_SECONDARY:
			if self.secondary_magazine.try_to_consume(self.__secondary_trigger_data.rounds_per_shot):
				super.__set_state(Weapon.State.SHOOTING_SECONDARY_SUCCEEDED)
				self.__secondary_trigger = TriggerState.SHOOTING
				self.__primary_hand.secondary_shoot()
				WeaponManager.secondary_timer.start(self.__secondary_trigger_data.shooting_time)
			else:
				super.__set_state(Weapon.State.SHOOTING_SECONDARY_FAILED)
				self.__secondary_trigger = TriggerState.NEEDS_RELOADING
				self.__primary_hand.secondary_empty()
				WeaponManager.secondary_timer.start(self.__secondary_trigger_data.empty_time)
		
		
		Weapon.State.EMPTY:
			# TODO: implement __weapon_data.disappears_when_empty
			assert(previous_state != Weapon.State.DEACTIVATING)
			# both triggers are empty so tell WeaponManager to deactivate this weapon
			WeaponManager.current_weapon_emptied.call_deferred(self) # important: WeaponManager must be notified *after* __set_state has returned
		
		Weapon.State.DEACTIVATING:
			self.__primary_hand.deactivating()
			self.__set_next_transition(Weapon.State.DEACTIVATED, self.__deactivating_time(previous_state))
		
		Weapon.State.DEACTIVATED:
			self.__primary_hand.deactivated()
			# TODO: support weapon_data.disappears_after_use; change it to disappears_when_empty, possibly moving this flag to trigger data, which allows for optional ammo reloads
	WeaponManager.weapon_activity_changed.emit(self)



func __primary_timer_ended() -> void:
	self.__primary_trigger = TriggerState.IDLE if self.primary_magazine.count > 0 else TriggerState.NEEDS_RELOADING
	if self.__secondary_trigger != TriggerState.SHOOTING and self.state > Weapon.State.IDLE:
		self.__set_state(Weapon.State.IDLE)

func __secondary_timer_ended() -> void:
	self.__secondary_trigger = TriggerState.IDLE if self.secondary_magazine.count > 0 else TriggerState.NEEDS_RELOADING
	if self.__primary_trigger != TriggerState.SHOOTING and self.state > Weapon.State.IDLE:
		self.__set_state(Weapon.State.IDLE)


# signal notification from InventoryManager when any pickable is picked up; subclasses may override if needed (e.g. DualWieldWeapon provides its own implementation)

func inventory_increased(item: InventoryManager.InventoryItem) -> void: # sent by any InventoryItem when it increments/decrements (while InventoryItem instances could send their own inventory_item_changed signals, allowing a WeaponTrigger to listen for a specific pickable, pickups are sufficiently rare that it shouldn't affect performance to listen to them all and filter here)
	if self.__primary_trigger == TriggerState.DISABLED and item == primary_magazine.inventory_item:
		self.__primary_trigger = TriggerState.NEEDS_RELOADING
		if self.state == Weapon.State.IDLE:
			self.__set_state(Weapon.State.RELOADING_PRIMARY)
	elif self.__secondary_trigger == TriggerState.DISABLED and item == secondary_magazine.inventory_item:
		self.__secondary_trigger = TriggerState.NEEDS_RELOADING
		if self.state == Weapon.State.IDLE:
			self.__set_state(Weapon.State.RELOADING_SECONDARY)


# Player shoots the weapon

func shoot(player: Player, is_primary: bool) -> void: # is_primary determines which hand shoots first
	# a trigger can only shoot while idle or, if triggers are independent, while the other trigger is shooting
	if self.state == Weapon.State.IDLE:
		self.__set_state(Weapon.State.SHOOTING_PRIMARY if is_primary else Weapon.State.SHOOTING_SECONDARY)
	
	elif self.state  > Weapon.State.IDLE:
		if is_primary:
			if self.__primary_trigger != TriggerState.SHOOTING and (__triggers_shoot_independently or self.__secondary_trigger != TriggerState.SHOOTING):
				self.__set_state(Weapon.State.SHOOTING_PRIMARY)
			else:
				return
		else:
			if self.__secondary_trigger != TriggerState.SHOOTING and (__triggers_shoot_independently or self.__primary_trigger != TriggerState.SHOOTING):
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

