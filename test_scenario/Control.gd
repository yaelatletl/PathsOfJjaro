extends Control

var viewports = []
var textures = []

onready var container = $TextureContainer
export(NodePath) var view1 = ""
export(NodePath) var view2 = ""

func _ready():
	add_viewport(get_node(view1))
	add_viewport(get_node(view2))


func add_viewport(viewport):
	var texture_format = [] #use as [texture_node, texture]
	var texture_node = TextureRect.new() 
	texture_node.name = "TextureNode"+str(len(textures))
	viewports.append(viewport)
	container.add_child(texture_node)
	texture_format.append(texture_node)
	texture_format.append(viewport.get_texture())
	textures.append(texture_format)

func _process(delta):
	for i in textures.size():
		textures[i][0].texture = viewports[i].get_texture()
