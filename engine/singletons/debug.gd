extends CanvasLayer

# Screen variables
var fullscreen : bool = false

@export var player: NodePath = ""
@onready var node_player = get_node(player)

# All debug inputs
var input : Dictionary = {}


func _process(_delta) -> void:
	
	# Calls the function to reset the game
	if Input.is_action_just_pressed("RESET_GAME"):
		get_tree().reload_current_scene()
		return
	
	# Calls the function to switch to fullscren or window
	if Input.is_action_just_pressed("TOGGLE_FULLSCREEN"):
		fullscreen = !fullscreen			
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (fullscreen) else Window.MODE_WINDOWED
				
	# Calls the function to show the framerate
	_display_framerate()


func _display_framerate() -> void:
	# If you don't have the framerate label
	if not has_node("framerate_label"): # TO DO: why? there is already a debug.tscn with a CanvasLayer, so why not just attach a Label node directly to that in editor?
		# Create a new label
		var framerate_label = Label.new()
		
		# Renames the label to framerate label
		framerate_label.name = "framerate_label"
		
		# Changes the position of the framerate label
		framerate_label.position = Vector2(5, 5)
		
		# Changes the color of the framerate label
		framerate_label.add_theme_color_override("font_color", Color("black"))
		
		# Adds the framerate label to the debug
		add_child(framerate_label)
	else:
		# Get the framerate label
		var framerate_label = $"framerate_label"
		
		# Changes the text of the label to that of the framerate
		framerate_label.text = str(node_player.run_speed," MPH")

