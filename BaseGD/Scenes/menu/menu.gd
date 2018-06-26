extends Viewport

var counter = 0
var actual_menu = 0

func _ready():
	
	
	var MSAA = ProjectSettings.get_setting("filters/msaa")
	var SSAO = ProjectSettings.get_setting("env/s_s_ambient_occlusion")
	var SSR = ProjectSettings.get_setting("env/s_s_reflections")
	var ANSIO = ProjectSettings.get_setting("filters/ansiotropic_filter_levels")
	
	
func _process(delta):
	if Input.is_action_pressed("ui_up"):
			counter +=1
	if Input.is_action_pressed("ui_down"):
			counter -=1
	if Input.is_action_pressed("ui_accept"):
		_Accept()
		
	if actual_menu == 0:
		if counter > 3:
			counter = 0
		if counter < 0: 
			counter = 3
			
	if actual_menu == 1:
		if counter > 3:
			counter = 0
			
func _Accept():
	if actual_menu == 0 and counter == 0:
		start_game()
	if actual_menu == 0 and counter == 1: 
		hehehe()
		
func _done():
	ProjectSettings.save()