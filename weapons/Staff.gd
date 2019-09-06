extends Spatial
export(int) var type = 1
export(PackedScene) var Projectile = Projectile
var can_shoot = true
var target = null

func _ready():
	$Reload.connect("timeout", self, "toggle_wind")
	
func toggle_wind():
	if not can_shoot:
		can_shoot = true

func fire():
	if can_shoot:
		var Bullet = Projectile.instance()
		Bullet.translation = to_global($BulletSpawn.translation) 
		Bullet.target = target
		get_node("/root").add_child(Bullet)
		can_shoot=false
	