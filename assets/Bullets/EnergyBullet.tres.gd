extends KinematicBody

export(float) var damage = 10
export(float) var speed = 20
export(bool) var follows = false
export(bool) var smart = false
var dead = false

#export(AnimatedSprite) var MainSprite = null
onready var Mask = preload("res://BaseGD/Bullets/Mark.tscn")
var destination = Vector3(0,0,0)
var target = null

func normal_movement():
	if target != null:
		if (is_on_ceiling() or is_on_wall() or is_on_floor()): # and $WallCheck.is_colliding(): # (or
			
			var normal = $WallCheck.get_collision_normal()
			var pos = $WallCheck.get_collision_point()
			if $WallCheck.is_colliding():
				if $WallCheck.get_collider() is StaticBody:
					var mark = Mask.instance()
					mark.translation = pos
					mark.look_at(normal)
					get_node("root/").add_child(mark.instance())
				
			
			set_process(false)
			set_physics_process(false)
			dead = true
			queue_free()
		if follows:
			#If you use the follows variable you must also set the target or else it will fail
			destination = target.translation
		else:
			pass
	 move_and_slide((destination).normalized()*speed)
	if translation.distance_to(Vector3(0,0,0)) > 150:
		dead = true
		queue_free()
		

func smart_movement():
	pass





func _ready():
	$Area.connect("body_entered", self, "_on_EnergyBullet_body_entered")
	destination = Vector3(target.translation.x, target.translation.y + 1.5, target.translation.z) - translation
func _process(delta):
	if not dead:
		if smart:
			smart_movement()
		else:
			normal_movement()
	






func _on_EnergyBullet_body_entered(body):
	
	if body is KinematicBody and body.get("health")!=null :
		body.health -= damage
		
	pass
