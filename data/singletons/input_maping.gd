extends Node

const CONFIG_FILE = "user://inputmap.cfg"
var INPUT_ACTIONS = []

func _ready():
	load_config()

func load_config():
	for actions in InputMap.get_actions():
		INPUT_ACTIONS.append(actions)
	var config = ConfigFile.new()
	var filecheck = File.new()
	if not filecheck.file_exists(CONFIG_FILE):
		config.save(CONFIG_FILE)
	var err = config.load(CONFIG_FILE)
	if err: # Assuming that file is missing, generate default config
		for action_name in INPUT_ACTIONS:
			var action_list = InputMap.get_action_list(action_name)
			# There could be multiple actions in the list, but we save the first one by default
			var scancode = OS.get_scancode_string(action_list[0].scancode)
			config.set_value("input", action_name, scancode)
		config.save(CONFIG_FILE)
	else: # ConfigFile was properly loaded, initialize InputMap
		for action_name in config.get_section_keys("input"):
			# Get the key scancode corresponding to the saved human-readable string
			var scancode = config.get_value("input", action_name)
			# Create a new event object based on the saved scancode
			var event = InputEventKey.new()
			event.scancode = scancode
			# Replace old action (key) events by the new one
			for old_event in InputMap.get_action_list(action_name):
				if old_event is InputEventKey:
					InputMap.action_erase_event(action_name, old_event)
			InputMap.action_add_event(action_name, event)

func save_to_config(section, key, value):
	"""Helper function to redefine a parameter in the settings file"""
	
	var config = ConfigFile.new()
	
	var err = config.load(CONFIG_FILE)
	if err:
		print("Error code when loading config file: ", err)
	else:
		config.set_value(section, key, value)
		config.save(CONFIG_FILE)

