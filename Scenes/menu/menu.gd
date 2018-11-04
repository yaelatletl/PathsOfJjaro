extends Viewport

var counter = 0
var actual_menu = 0

func _ready():
	
	
	var MSAA = ProjectSettings.get_setting("filters/msaa")
	var SSAO = ProjectSettings.get_setting("env/s_s_ambient_occlusion")
	var SSR = ProjectSettings.get_setting("env/s_s_reflections")
	var ANSIO = ProjectSettings.get_setting("filters/ansiotropic_filter_levels")
	
	

			

		
func _done():
	ProjectSettings.save()