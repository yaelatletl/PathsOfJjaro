extends Navigation
var Areas = []
var Meshes = {}
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _enter_tree():
	for nodes in get_children(): 
		var node = nodes
		
		if node.is_class("Area"):
			Areas.insert (Areas.size()+1, node)
			
		if node.is_class("MeshInstance"):
			Meshes.insert(Meshes.size()+1,node)
			

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
