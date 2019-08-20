tool
extends Spatial
export(bool) var Dynamic = false
export(Environment) var Env = null
var Top 
var Front
var Back 
var Left 
var Right
var Bottom

func _ready():
	Top = $Viewport5.get_texture()
	Front = $Viewport.get_texture()
	Back = $Viewport4.get_texture()
	Left = $Viewport2.get_texture()
	Right = $Viewport3.get_texture()
	Bottom = $Viewport6.get_texture()
	update_env()
	if not Dynamic:
		update_pos()
	

func _process(delta):
	if Dynamic:
		update_pos()


func update_pos():
	$Viewport6/Bottom.translation = translation
	$Viewport5/Top.translation = translation
	$Viewport4/Back.translation = translation
	$Viewport3/Right.translation = translation
	$Viewport2/Left.translation = translation
	$Viewport/Front.translation = translation
	
func update_env():
	if Env != null:
		$Viewport6/Bottom.environment = Env
		$Viewport5/Top.environment = Env
		$Viewport4/Back.environment = Env
		$Viewport3/Right.environment = Env
		$Viewport2/Left.environment = Env
		$Viewport/Front.environment = Env