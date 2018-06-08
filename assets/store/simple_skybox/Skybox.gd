tool
extends Spatial

onready var sky_mesh = preload("res://assets/simple_skybox/skybox.obj")

var TextureFront = null
var TextureBack = null
var TextureBottom = null
var TextureUp = null
var TextureLeft = null
var TextureRight = null

func create_mat(texture):
	var m = SpatialMaterial.new()
	m.flags_unshaded = true
	m.albedo_texture = texture
	return m

func _ready():
	TextureFront = $SkyboxGetter.Front
	TextureLeft = $SkyboxGetter.Left
	TextureRight = $SkyboxGetter.Right
	TextureBack = $SkyboxGetter.Back
	TextureUp = $SkyboxGetter.Up
	TextureBottom = $SkyboxGetter.Bottom
	var i_mesh = MeshInstance.new()
	i_mesh.name = "SkyMeshInstance"
	i_mesh.mesh = sky_mesh
	add_child(i_mesh)
	i_mesh.set_surface_material(0, create_mat(TextureBottom))
	i_mesh.set_surface_material(1, create_mat(TextureUp))
	i_mesh.set_surface_material(2, create_mat(TextureFront))
	i_mesh.set_surface_material(3, create_mat(TextureLeft))
	i_mesh.set_surface_material(4, create_mat(TextureBack))
	i_mesh.set_surface_material(5, create_mat(TextureRight))
	