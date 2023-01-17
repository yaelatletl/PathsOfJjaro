extends ProjectileWeapon
class_name SpecialWeapon
#Modes for the second click
enum FIRE_MODE{
	AREA, #For meele
	RAYCAST, 
	PROJECTILE
}
enum FUNCTION_MODE{
	ZOOM, 
	TOGGLE_SPREAD,
	SECONDARY_FIRE,
	TOGGLE_SETTINGS,
	ZOOM_TOGGLE_SETTINGS
}

enum MODIFIER_TYPE{
	NONE, 
	ON_RELEASE,
	ON_RELEASE_IF_LOADED,
	ON_RELEASE_OR_AUTO,
	AUTO_RELEASE_IF_LOADED,
}

var right_click_mode = FUNCTION_MODE.ZOOM

var primary_fire_mode = FIRE_MODE.RAYCAST
var secondary_fire_mode = FIRE_MODE.PROJECTILE

var secondary_firerate = 0
remote var secondary_bullets = 0
remote var secondary_ammo = 0
var secondary_max_bullets = 0
var secondary_damage = 0
var secondary_reload_speed = 0
var secondary_use_randomness = false
var secondary_projectile_type = 0
var secondary_spread_pattern = []
var secondary_spread_multiplier = 0
var secondary_max_range = 0
var secondary_max_random_spread_x = 0
var secondary_max_random_spread_y = 0

var uses_separate_ammo = true
var switch = false

var primary_modifier_timer = 0
var current_primary_modifier_time = 0
var secondary_modifier_timer = 0
var current_secondary_modifier_time = 0
var primary_modifier_type = MODIFIER_TYPE.NONE
var secondary_modifier_type = MODIFIER_TYPE.NONE

var primary_pressed = false
var secondary_pressed = false

var primary_waiting_for_release = false
var secondary_waiting_for_release = false

var primary_just_auto_triggered = false
var secondary_just_auto_triggered = false

signal trigger_released

func _ready() -> void:
	._ready()
	setup_spread(secondary_spread_pattern, secondary_spread_multiplier, secondary_max_range, "secondary")

func _physics_process(delta):
	if actor == null:
		return
	if actor.input["zoom"] and right_click_mode == FUNCTION_MODE.ZOOM_TOGGLE_SETTINGS:
		switch = true
	elif right_click_mode == FUNCTION_MODE.ZOOM_TOGGLE_SETTINGS:
		switch = false
	primary_pressed = actor.input["shoot"]
	secondary_pressed = actor.input["zoom"]
	if not primary_pressed and primary_waiting_for_release:
		_shoot_cast("", 0)
	if not secondary_pressed and secondary_waiting_for_release:	
		_shoot_cast("secondary", 0)
	
	if not primary_pressed and primary_just_auto_triggered:
		primary_just_auto_triggered = false
	if not secondary_pressed and secondary_just_auto_triggered:
		secondary_just_auto_triggered = false

	if primary_modifier_type != MODIFIER_TYPE.NONE and primary_pressed:
		if current_primary_modifier_time < primary_modifier_timer:
			current_primary_modifier_time += delta
	else:
		current_primary_modifier_time = 0

	if secondary_modifier_type != MODIFIER_TYPE.NONE and secondary_pressed:
		if current_secondary_modifier_time < secondary_modifier_timer:
			current_secondary_modifier_time += delta
	else:
		current_secondary_modifier_time = 0

func shoot(delta) -> void: #Implemented as a virtual method, so that it can be overriden by child classes
	if primary_just_auto_triggered:
		return
	_shoot(self, delta, bullets, max_bullets, ammo, reload_speed, firerate, "", "ammo", "bullets", true)


func setup_secondary_fire(mode, firerate, bullets, ammo, max_bullets, damage, reload_speed, use_randomness, spread_pattern, spread_multiplier, projectile) -> void:
	projectile_type = projectile
	secondary_fire_mode = mode
	secondary_projectile_type = int(projectile)
	secondary_spread_pattern = spread_pattern
	secondary_spread_multiplier = spread_multiplier
	secondary_firerate = firerate
	secondary_bullets = bullets
	secondary_ammo = ammo
	secondary_max_bullets = max_bullets
	secondary_damage = damage
	secondary_reload_speed = reload_speed
	secondary_use_randomness = use_randomness

func _zoom(input, _delta) -> void:
	if not check_relatives():
		if spatial_parent!= null:
			update_spatial_parent_relatives(spatial_parent)		
		return
	if input:
		match right_click_mode:
			FUNCTION_MODE.ZOOM:
				make_zoom(input, _delta)
			FUNCTION_MODE.TOGGLE_SPREAD:
				pass
			FUNCTION_MODE.SECONDARY_FIRE:
				if secondary_just_auto_triggered:
					return
				secondary_fire(_delta)
			FUNCTION_MODE.TOGGLE_SETTINGS:
				switch = not switch
			FUNCTION_MODE.ZOOM_TOGGLE_SETTINGS:
				make_zoom(input, _delta)
			FUNCTION_MODE.TOGGLE_SPREAD:
				switch = not switch
				
func secondary_fire(delta) -> void:
	if uses_separate_ammo:
		_shoot(self, delta, secondary_bullets, secondary_max_bullets, secondary_ammo, secondary_reload_speed, secondary_firerate, "secondary", "secondary_ammo", "secondary_bullets", false)
	else:
		_shoot(self, delta, bullets, max_bullets, ammo, secondary_reload_speed, secondary_firerate, "secondary", "ammo", "bullets", false)

func _shoot_cast(relative_node = "", delta=0)-> void:
	if not check_relatives():
		if spatial_parent!= null:
			update_spatial_parent_relatives(spatial_parent)
		return
	var should_trigger = false
		
	match relative_node:
		"":
			match primary_modifier_type:
				MODIFIER_TYPE.NONE:
					should_trigger = true
				MODIFIER_TYPE.AUTO_RELEASE_IF_LOADED:
					if current_primary_modifier_time >= primary_modifier_timer:
						should_trigger = true
						primary_just_auto_triggered = true
					else:
						return
				MODIFIER_TYPE.ON_RELEASE:
					if primary_pressed:
						primary_waiting_for_release = true
						return
					elif not primary_pressed:
						if primary_waiting_for_release and current_primary_modifier_time > 0:
							should_trigger = true
				MODIFIER_TYPE.ON_RELEASE_IF_LOADED:
					if current_primary_modifier_time < primary_modifier_timer:
						return
					elif current_primary_modifier_time >= primary_modifier_timer:
						if primary_pressed:
							primary_waiting_for_release = true
							return
						elif not primary_pressed and primary_waiting_for_release:
							should_trigger = true
				MODIFIER_TYPE.ON_RELEASE_OR_AUTO:
					if current_primary_modifier_time < primary_modifier_timer and primary_pressed:
						primary_waiting_for_release = true
						return
					elif current_primary_modifier_time >= primary_modifier_timer:
						should_trigger = true
						primary_just_auto_triggered = true
					elif not primary_pressed and primary_waiting_for_release:
						should_trigger = true
		"secondary":
			match secondary_modifier_type:
				MODIFIER_TYPE.NONE:
					should_trigger = true
				MODIFIER_TYPE.AUTO_RELEASE_IF_LOADED:
					if current_secondary_modifier_time >= secondary_modifier_timer:
						should_trigger = true
						secondary_just_auto_triggered = true
					else:
						return
				MODIFIER_TYPE.ON_RELEASE:
					if secondary_pressed:
						secondary_waiting_for_release = true
						return
					elif not secondary_pressed:
						if secondary_waiting_for_release and current_secondary_modifier_time > 0:
							should_trigger = true
				MODIFIER_TYPE.ON_RELEASE_IF_LOADED:
					if current_secondary_modifier_time < secondary_modifier_timer:
						return
					elif current_secondary_modifier_time >= secondary_modifier_timer: #Maybe too explicit? Will think about it
						if secondary_pressed:
							secondary_waiting_for_release = true
							return
						elif not secondary_pressed and secondary_waiting_for_release:
							should_trigger = true
				MODIFIER_TYPE.ON_RELEASE_OR_AUTO:
					if current_secondary_modifier_time < secondary_modifier_timer and secondary_pressed:
						secondary_waiting_for_release = true
						return
					elif current_secondary_modifier_time >= secondary_modifier_timer:
						should_trigger = true
						secondary_just_auto_triggered = true
					elif not secondary_pressed and secondary_waiting_for_release:
						should_trigger = true
	if not should_trigger:
		return
	else:
		if secondary_waiting_for_release:
			current_secondary_modifier_time = 0
			secondary_waiting_for_release = false
		if primary_waiting_for_release:
			current_primary_modifier_time = 0
			primary_waiting_for_release = false

	if relative_node == "secondary" or (right_click_mode != FUNCTION_MODE.TOGGLE_SPREAD and switch):
		match secondary_fire_mode:
			FIRE_MODE.RAYCAST:
				shoot_raycast(secondary_use_randomness, secondary_max_random_spread_x, secondary_max_random_spread_y, secondary_max_range, relative_node)
			FIRE_MODE.PROJECTILE:
				shoot_projectile(relative_node)
			FIRE_MODE.AREA:
				pass
	else:
		if right_click_mode == FUNCTION_MODE.TOGGLE_SPREAD and switch:
			relative_node = "secondary"
		match primary_fire_mode:
			FIRE_MODE.RAYCAST:
				shoot_raycast(uses_randomness, max_random_spread_x, max_random_spread_y, max_range, relative_node)
			FIRE_MODE.PROJECTILE:
				shoot_projectile(relative_node)
			FIRE_MODE.AREA:
				pass

func secondary_reload() -> void:
	if uses_separate_ammo:
		_reload(self, secondary_bullets, secondary_max_bullets, secondary_ammo, "secondary_ammo", "secondary_bullets", secondary_reload_speed) 
	else:
		_reload(self, bullets, max_bullets, ammo, "ammo", "bullets", secondary_reload_speed) 
