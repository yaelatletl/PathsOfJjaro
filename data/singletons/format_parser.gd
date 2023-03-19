# This class provides static methods for creating in-game objects 
# using json descriptions.
extends Node
class_name FormatParser

enum MODIFIER_TYPE{
	NONE, 
	ON_RELEASE,
	ON_RELEASE_IF_LOADED,
	ON_RELEASE_OR_AUTO,
	AUTO_RELEASE_IF_LOADED,
}

static func parse_spread_pattern(pattern) -> Array:
	var result = []
	for pair in pattern:
		result.append(Vector2(pair[0], pair[1]))
	return result

static func to_modifier(input) -> int:
	if input is String:
		match input:
			"None":
				return MODIFIER_TYPE.NONE
			"OnRelease":
				return MODIFIER_TYPE.ON_RELEASE
			"OnReleaseIfLoaded":
				return MODIFIER_TYPE.ON_RELEASE_IF_LOADED
			"OnReleaseOrAuto":
				return MODIFIER_TYPE.ON_RELEASE_OR_AUTO
			"AutoReleaseIfLoaded":
				return MODIFIER_TYPE.AUTO_RELEASE_IF_LOADED
			_:
				return MODIFIER_TYPE.NONE
	elif input is int:
		return input
	else:
		return MODIFIER_TYPE.NONE

static func safe_assign(target, dict, property, key, array_index = -1) -> void:
	if key in dict and array_index == -1:
		target.set(property, dict[key])
		return
	elif array_index != -1 and key in dict:
		target.set(property, dict[key][array_index])
		return
	printerr("Error: Could not assign property ", str(property), " to ", str(target), " from dict ", dict, " with key ", key, " and array index ", str(array_index))
		
static func weapon_from_json( path : String, weapon_parent : Node ) -> Weapon: 
	var result = null
	var file : File = File.new()
	var temp = file.open(path, File.READ)
	var test_json_conv = JSON.new()
	test_json_conv.parse(file.get_as_text())
	var json : JSON= test_json_conv.get_data()
	file.close()
	var data = json.result
	if data is Dictionary:
		var type = int(data.type) # 0 = melee, 1 = raycast, 2 = projectile 
		match type:
			0:
				result = Weapon.new() #Change to melee (Using cones I guess.)
			1:
				result = Weapon.new()
			2:
				result = ProjectileWeapon.new()
				result.set_projectile(int(data.projectileIndex)) 
			3:
				result = SpecialWeapon.new()
				result.set_projectile(int(data.projectileIndex)) 
				result.setup_secondary_fire(
					int(data.secondaryFireMode),
					data.secondaryFireRate, 
					data.secondaryBullets, 
					data.secondaryAmmo, 
					data.secondaryMaxBullets, 
					data.secondaryDamage, 
					data.secondaryReloadSpeed, 
					bool(data.secondaryRandomness), 
					parse_spread_pattern(data.secondarySpreadPattern), 
					data.secondarySpreadMultiplier,
					int(data.secondaryProjectileIndex))
				result.right_click_mode = int(data.specialType)
				result.primary_fire_mode = int(data.primaryFireMode)	
				result.secondary_max_range = int(data.secondaryRange)
				result.secondary_max_random_spread_x = data.secondaryRandomSpread[0]
				result.secondary_max_random_spread_y = data.secondaryRandomSpread[1]
				result.uses_separate_ammo = bool(data.usesSecondaryAmmo)
				result.primary_modifier_type = to_modifier(data.primaryModifierType)
				result.secondary_modifier_type = to_modifier(data.secondaryModifierType)
				safe_assign(result, data, "primary_modifier_timer", "primaryModifierTimer")
				safe_assign(result, data, "secondary_modifier_timer", "secondaryModifierTimer")

		result.spatial_parent = weapon_parent
		result.gun_name = data.name
		result.firerate = data.fireRate
		result.bullets = data.bullets
		result.ammo = data.ammo
		result.max_bullets = data.maxBullets
		result.damage = data.damage
		result.reload_speed = data.reloadSpeed
		result.uses_randomness = bool(data.randomness)
		result.spread_pattern = parse_spread_pattern(data.spreadPattern)
		result.spread_multiplier = data.spreadMultiplier
		result.max_random_spread_x = data.randomSpread[0]
		result.max_random_spread_y = data.randomSpread[1]
		result.zoom_fov = data.defaultZoomFOV
		result.max_range = data.range

	return result
