class_name DualWieldWeapon extends Weapon


# engine/weapons/DualWieldWeapon.gd -- two single-purpose guns; the Player may have 0, 1, or 2 guns available at any time, so this class must be able to show/hide either hand or both hands as gun and ammo availability changes


# MCR: pistol, shotgun (TBC - M1 doesn't have it so don't bother implementing one-handed reload for now)
#
# (note: fist is a subclass of SinglePurposeWeapon: while the view displays two hands they operate as one weapon, firing at a constant rate)


# TO DO: implement __weapon_data.disappears_when_empty


#var __triggers_reload_independently: bool # ignore this for now; not needed for MCR

var __has_second_gun: bool # true if player has 2 guns; false if 1 or 0 guns
var __repeat_firing := false # hands swap automatically while either trigger key is held


# initialization

func configure(weapon_data: Dictionary) -> void:
	# assert(weapon_data.secondary_trigger == null) # primary_trigger definition is used for both guns
	super.configure(weapon_data)
	self.__secondary_trigger_data = weapon_data.primary_trigger
	assert(self.weapon_item.max_count == 2)
	assert(self.weapon_item.count in [0, 1, 2])
	#__triggers_reload_independently = weapon_data.triggers_reload_independently


# FSM

func __set_state(next_state: State) -> void:
	assert(next_state != self.state) # DEBUG: we could ignore non-transition transitions,q better to catch them during testing as they're likely due to bad implementation
	var previous_state = self.state
	super.__set_state(next_state)
	var wait_time := 0.0
	match next_state:
		Weapon.State.ACTIVATING:
			# check if there's enough ammo for one or both guns and activate hand[s] accordingly
			var remaining_magazines = self.primary_magazine.inventory_item.count
			self.__primary_trigger = TriggerState.NEEDS_ENABLED
			if primary_magazine.count == 0:
				if remaining_magazines == 0:
					self.__primary_trigger = TriggerState.DISABLED
				remaining_magazines -= 1
			# if player only has 1 gun, it is primary
			self.__secondary_trigger = TriggerState.DISABLED
			__has_second_gun = self.weapon_item.count == 2
			if __has_second_gun and (secondary_magazine.count > 0 or remaining_magazines > 0):
				self.__secondary_trigger = TriggerState.NEEDS_ENABLED
			self.__set_next_transition(Weapon.State.REACTIVATING)
			#print("Activating dual-wield weapon ", self.name_for_trigger_state(self.__primary_trigger), "  ", self.name_for_trigger_state(self.__secondary_trigger))
						
		Weapon.State.REACTIVATING: # this is a separate state is if player picks up ammo for empty gun while ACTIVATING, at which point we don't want to re-enter ACTIVATING state
			self.__primary_hand.move_to_center()
			self.__secondary_hand.move_to_center()
			if self.__primary_trigger == TriggerState.NEEDS_ENABLED:
				self.__primary_hand.activating()
			if self.__secondary_trigger == TriggerState.NEEDS_ENABLED:
				self.__secondary_hand.activating()
			if self.__primary_trigger == TriggerState.DISABLED or self.__secondary_trigger == TriggerState.DISABLED:
				self.__primary_hand.move_to_center(true)
				self.__secondary_hand.move_to_center(true)
			else:
				self.__primary_hand.move_to_side(self.__primary_trigger == TriggerState.NEEDS_ENABLED)
				self.__secondary_hand.move_to_side(self.__secondary_trigger == TriggerState.NEEDS_ENABLED)
			self.__set_next_transition(Weapon.State.ACTIVATED, self.__activating_time(previous_state))
		
		Weapon.State.ACTIVATED:
			if self.__primary_trigger == TriggerState.NEEDS_ENABLED:
				self.__primary_trigger = TriggerState.IDLE if primary_magazine.count > 0 else TriggerState.NEEDS_RELOADING
				self.__primary_hand.activated()
			if self.__secondary_trigger == TriggerState.NEEDS_ENABLED:
				self.__secondary_trigger = TriggerState.IDLE if secondary_magazine.count > 0 else TriggerState.NEEDS_RELOADING
				self.__secondary_hand.activated()
			self.__set_next_transition(Weapon.State.IDLE)
		
		Weapon.State.IDLE:
			if self.__primary_trigger == TriggerState.NEEDS_ENABLED or self.__secondary_trigger == TriggerState.NEEDS_ENABLED:
				self.__set_next_transition(Weapon.State.REACTIVATING)
			elif self.__primary_trigger == TriggerState.NEEDS_RELOADING:
				self.__set_next_transition(Weapon.State.RELOADING_PRIMARY)
			elif self.__secondary_trigger == TriggerState.NEEDS_RELOADING:
				self.__set_next_transition(Weapon.State.RELOADING_SECONDARY)
			else:
				if self.__primary_trigger > TriggerState.IDLE:
					self.__primary_trigger = TriggerState.IDLE
				if self.__secondary_trigger > TriggerState.IDLE:
					self.__secondary_trigger = TriggerState.IDLE
		
		Weapon.State.RELOADING_PRIMARY:
			if self.primary_magazine.try_to_refill():
				self.__primary_hand.reload()
				self.__secondary_hand.reload_other()
				self.__set_next_transition(Weapon.State.RELOADING_PRIMARY_ENDED, self.__primary_trigger_data.reloading_time)
			else:
				self.__primary_trigger = TriggerState.DISABLED
				self.__primary_hand.deactivating()
				if secondary_magazine.is_available:
					self.__secondary_hand.move_to_center()
				elif self.__secondary_trigger != TriggerState.DISABLED:
					self.__secondary_trigger = TriggerState.DISABLED
					self.__secondary_hand.deactivating()
				if self.__secondary_trigger == TriggerState.DISABLED:
					self.__set_next_transition(Weapon.State.EMPTY)
				else:
					self.__set_next_transition(Weapon.State.IDLE, self.__deactivating_time(previous_state))
		
		Weapon.State.RELOADING_SECONDARY:
			if self.secondary_magazine.try_to_refill():
				self.__secondary_hand.reload()
				self.__primary_hand.reload_other()
				self.__set_next_transition(Weapon.State.RELOADING_SECONDARY_ENDED, self.__secondary_trigger_data.reloading_time)
			else:
				self.__secondary_trigger = TriggerState.DISABLED
				self.__secondary_hand.deactivating()
				if primary_magazine.is_available:
					self.__primary_hand.move_to_center()
				elif self.__primary_trigger != TriggerState.DISABLED:
					self.__primary_trigger = TriggerState.DISABLED
					self.__primary_hand.deactivating()
				if self.__primary_trigger == TriggerState.DISABLED:
					self.__set_next_transition(Weapon.State.EMPTY)
				else:
					self.__set_next_transition(Weapon.State.IDLE, self.__deactivating_time(previous_state))
		
		Weapon.State.RELOADING_PRIMARY_ENDED:
			self.__primary_trigger = TriggerState.IDLE
			self.__set_next_transition(Weapon.State.IDLE)
		
		Weapon.State.RELOADING_SECONDARY_ENDED:
			self.__secondary_trigger = TriggerState.IDLE
			self.__set_next_transition(Weapon.State.IDLE)
		
		Weapon.State.SHOOTING_PRIMARY:
			if self.primary_magazine.try_to_consume(self.__primary_trigger_data.rounds_per_shot):
				# set the interlock on the other gun; this prevents the other gun shooting until the current gun is halfway through its shooting sequence
				if self.__secondary_trigger >= TriggerState.IDLE:
					self.__secondary_trigger = TriggerState.INTERLOCKED
				super.__set_state(Weapon.State.SHOOTING_PRIMARY_SUCCEEDED)
				self.__primary_trigger = TriggerState.SHOOTING
				self.__primary_hand.shoot()
				self.__set_next_transition(Weapon.State.PRIMARY_RELEASES_INTERLOCK, self.__primary_trigger_data.shooting_time / 2)
			else:
				self.__primary_trigger = TriggerState.NEEDS_RELOADING
				super.__set_state(Weapon.State.SHOOTING_PRIMARY_FAILED)
				self.__primary_hand.empty()
				self.__set_next_transition(Weapon.State.IDLE, self.__primary_trigger_data.empty_time)
		
		Weapon.State.SHOOTING_SECONDARY:
			if self.secondary_magazine.try_to_consume(self.__secondary_trigger_data.rounds_per_shot):
				if self.__primary_trigger >= TriggerState.IDLE:
					self.__primary_trigger = TriggerState.INTERLOCKED
				super.__set_state(Weapon.State.SHOOTING_SECONDARY_SUCCEEDED)
				self.__secondary_trigger = TriggerState.SHOOTING
				self.__secondary_hand.shoot()
				self.__set_next_transition(Weapon.State.SECONDARY_RELEASES_INTERLOCK, self.__secondary_trigger_data.shooting_time / 2)
			else:
				self.__secondary_trigger = TriggerState.NEEDS_RELOADING
				super.__set_state(Weapon.State.SHOOTING_SECONDARY_FAILED)
				self.__secondary_hand.empty()
				self.__set_next_transition(Weapon.State.IDLE, self.__secondary_trigger_data.empty_time)
		
		Weapon.State.PRIMARY_RELEASES_INTERLOCK:
			# release the interlock on the secondary gun so it may start shooting while the primary finishes; for now, this is hardcoded for dual pistols
			if self.__secondary_trigger == TriggerState.INTERLOCKED: # may also be DISABLED
				self.__secondary_trigger = TriggerState.IDLE if secondary_magazine.count > 0 else TriggerState.NEEDS_RELOADING
			if primary_magazine.count == 0:
				self.__primary_trigger = TriggerState.NEEDS_RELOADING
			self.__set_next_transition(Weapon.State.IDLE, self.__primary_trigger_data.shooting_time / 2) # run the remaining time on the primary hand while it finishes shooting
		
		Weapon.State.SECONDARY_RELEASES_INTERLOCK:
			# release the interlock on the primary gun so it may start shooting while the secondary finishes; for now, this is hardcoded for dual pistols
			if self.__primary_trigger == TriggerState.INTERLOCKED: # may also be DISABLED
				self.__primary_trigger = TriggerState.IDLE if primary_magazine.count > 0 else TriggerState.NEEDS_RELOADING
			if secondary_magazine.count == 0:
				self.__secondary_trigger = TriggerState.NEEDS_RELOADING
			self.__set_next_transition(Weapon.State.IDLE, self.__secondary_trigger_data.shooting_time / 2) # run the remaining time on the secondary hand while it finishes shooting
		
		Weapon.State.EMPTY:
			# both triggers are empty so tell WeaponManager to deactivate this weapon
			WeaponManager.current_weapon_emptied.call_deferred(self) # important: WeaponManager must be notified *after* __set_state has returned
		
		Weapon.State.DEACTIVATING:
			#print("Deactivating dual-wield weapon ", self.name_for_trigger_state(self.__primary_trigger), "  ", self.name_for_trigger_state(self.__secondary_trigger))
			if self.__primary_trigger != TriggerState.DISABLED:
				self.__primary_trigger = TriggerState.DISABLED
				self.__primary_hand.deactivating()
			if self.__secondary_trigger != TriggerState.DISABLED:
				self.__secondary_trigger = TriggerState.DISABLED
				self.__secondary_hand.deactivating()
			self.__set_next_transition(Weapon.State.DEACTIVATED, self.__deactivating_time(previous_state))
		
		Weapon.State.DEACTIVATED:
			self.__primary_hand.deactivated()
			self.__secondary_hand.deactivated()
	WeaponManager.weapon_activity_changed.emit(self)



func secondary_needs_reload() -> bool:
	return __has_second_gun and self.secondary_magazine.count == 0


# signal notification from InventoryManager when any pickable is picked up

func inventory_increased(item: InventoryManager.InventoryItem) -> void: # sent by any InventoryItem when it increments/decrements (while InventoryItem instances could send their own inventory_item_changed signals, allowing a WeaponTrigger to listen for a specific pickable, pickups are sufficiently rare that it shouldn't affect performance to listen to them all and filter here)
	if item == self.weapon_item: # picked up second weapon, so activate it now if currently IDLE or on next IDLE if busy
		__has_second_gun = true
		self.__secondary_trigger = TriggerState.NEEDS_ENABLED
		if self.state == Weapon.State.IDLE:
			self.__set_state(Weapon.State.REACTIVATING) # for now, pause shooting primary while activating secondary; TO DO: check Classic, and if secondary can activate while primary is mid-shot, amend this
	
	elif item == self.primary_magazine.inventory_item:
		if self.primary_needs_reload():
			if self.state == Weapon.State.IDLE:
				if self.__primary_trigger == TriggerState.DISABLED:
					self.__primary_trigger = TriggerState.NEEDS_ENABLED
					self.__set_state(Weapon.State.REACTIVATING)
				else:
					self.__primary_trigger = TriggerState.NEEDS_RELOADING
					self.__set_state(Weapon.State.RELOADING_PRIMARY)
			elif self.__primary_trigger == TriggerState.DISABLED:
				self.__primary_trigger = TriggerState.NEEDS_ENABLED # primary will be reactivated once weapon has finished its current activity and returns to IDLE
			# else trigger is currenly busy
		elif self.secondary_needs_reload():
			if self.state == Weapon.State.IDLE:
				if self.__secondary_trigger == TriggerState.DISABLED:
					self.__secondary_trigger = TriggerState.NEEDS_ENABLED
					self.__set_state(Weapon.State.REACTIVATING)
				else:
					self.__secondary_trigger = TriggerState.NEEDS_RELOADING
					self.__set_state(Weapon.State.RELOADING_SECONDARY)
			elif self.__secondary_trigger == TriggerState.DISABLED:
				self.__secondary_trigger = TriggerState.NEEDS_ENABLED # secondary will be reactivated once weapon has finished its current activity and returns to IDLE


# Player shoots the weapon

func shoot(player: Player, is_primary: bool) -> void: # is_primary determines which hand shoots first
	#print("shoot ", debug_state, "  ", self.name_for_trigger_state(self.__primary_trigger),  "  ", self.name_for_trigger_state(self.__secondary_trigger))
	match self.state:
		Weapon.State.IDLE:
			if __has_second_gun:
				if is_primary:
					self.__set_state(Weapon.State.SHOOTING_SECONDARY if self.__primary_trigger == TriggerState.DISABLED else Weapon.State.SHOOTING_PRIMARY)
				else:
					self.__set_state(Weapon.State.SHOOTING_PRIMARY if self.__secondary_trigger == TriggerState.DISABLED else Weapon.State.SHOOTING_SECONDARY)
				__repeat_firing = true
			else:
				self.__set_state(Weapon.State.SHOOTING_PRIMARY)
		
		# RELEASE_PRIMARY/SECONDARY_TRIGGER is called halfway through one gun's shooting sequence and will release the lock on the other gun if both guns are available, giving the other hand opportunity to start shooting if the trigger key is held down, doubling the firing rate
		Weapon.State.SECONDARY_RELEASES_INTERLOCK:
			if __repeat_firing and self.__primary_trigger == TriggerState.IDLE:
				self.__set_state(Weapon.State.SHOOTING_PRIMARY)
		
		Weapon.State.PRIMARY_RELEASES_INTERLOCK:
			if __repeat_firing and self.__secondary_trigger == TriggerState.IDLE:
					self.__set_state(Weapon.State.SHOOTING_SECONDARY)
		
		_: # can't fire ATM
			return
	
	match self.state: # confirm projectile should be launched
		Weapon.State.SHOOTING_PRIMARY_SUCCEEDED:
			self.spawn_primary_projectile(player)
		Weapon.State.SHOOTING_SECONDARY_SUCCEEDED:
			self.spawn_secondary_projectile(player)


func trigger_just_released(is_primary: bool) -> void:
	__repeat_firing = false


