extends Spatial
export(int) var type = 1
export(PackedScene) var Projectile = preload("res://BaseGD/Bullets/EnergyBullet.tscn")
export(PackedScene) var Missile = null
var can_shoot = true
var can_shoot_missile = true
var target = null


func _ready():
	$Reload.connect("timeout", self, "toggle_wind")
	$Reload2.connect("timeout", self, "toggle_wind_missile")
	
func toggle_wind():
	if not can_shoot:
		can_shoot = true
		
func toggle_wind_missile():
	if not can_shoot_missile:
		can_shoot_missile = true
		
		
func fire_missile():
	if can_shoot_missile:
		var Miss = Missile.instance()
		var Miss2 = Missile.instance()
		Miss.translation = to_global($MissileSpawn1.translation)
		Miss2.translation = to_global($MissileSpawn2.translation)
		Miss.target = target
		Miss2.target = target
		get_node("/root").add_child(Miss)
		get_node("/root").add_child(Miss2)
		can_shoot_missile = false
		
func fire():
	if can_shoot:
		var Bullet = Projectile.instance()
		var Bullet2 = Projectile.instance()
		Bullet.translation = to_global($FireSpawn1.translation)
		Bullet.target = target
		Bullet2.translation = to_global($FireSpawn2.translation)
		Bullet2.target = target
		get_node("/root").add_child(Bullet)
		get_node("/root").add_child(Bullet2)
		can_shoot=false
