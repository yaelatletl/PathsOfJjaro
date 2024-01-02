class_name FistWeapon extends SinglePurposeWeapon


# assets/weapons/FistWeapon.gd -- animates 2 WIH fists, auto-swapping between them (this is purely cosmetic)


var __animate_primary_hand := true
var __repeating := false


func __activating_primary() -> void:
	self.__primary_hand.activating()
	self.__secondary_hand.activating()

func __activated_primary() -> void:
	self.__primary_hand.activated()
	self.__secondary_hand.activated()


func __shooting_primary() -> void:
	(self.__primary_hand if __animate_primary_hand else self.__secondary_hand).shoot()
	__animate_primary_hand = not __animate_primary_hand


func __deactivating_primary() -> void:
	self.__primary_hand.deactivating()
	self.__secondary_hand.deactivating()

func __deactivated_primary() -> void:
	self.__primary_hand.deactivated()
	self.__secondary_hand.deactivated()


func spawn_primary_projectile(player: Player) -> void:
	for i in range(0, __primary_trigger_data.projectiles_per_shot):
		# TO DO: if Player is sprinting forward (as indicated by velocity and is_on_floor) it should spawn a MAJOR_FIST projectile (__secondary_projectile_class) instead of a MINOR_FIST projectile (__primary_projectile_class)
		__primary_projectile_class.spawn(player.global_head_position(), player.global_look_direction(), player)



func shoot(player: Player, is_primary: bool) -> void:
	if not __repeating:
		__repeating = true
		__animate_primary_hand = is_primary
	super.shoot(player, is_primary)


func trigger_just_released(is_primary: bool) -> void:
	__repeating = false

