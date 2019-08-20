#This script automatically generates navigation meshes for every MeshInstance 
# child and subchild 


extends Navigation

func _ready():
	
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	TraceAllMeshes(self)


func TraceAllMeshes(node):
	for N in node.get_children():
		if N.is_class("MeshInstance"):
			var a = NavigationMeshInstance.new()
			N.add_child(a)
			print(a)
			a.navmesh = NavigationMesh.new()
			a.navmesh.create_from_mesh(N.mesh)
			navmesh_add(a, Transform())
#			navmesh_add(a, N.transform)
		if N.get_child_count() > 0:
			TraceAllMeshes(N)
