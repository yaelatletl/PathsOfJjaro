extends Node

const MAP_PATH = "res://maps/"
const CHAR_PATH = "res://characters/"

var scenarios = {}
# Have them as a dict, we access by scenario name all the levels in the scenario
var characters = {}

var current_scenario = 0

#we load all pck files in the directory "maps" and we create a list of all the maps in the package

func explore_folder(path : String, callable : Callable, const_path : String, dict : Dictionary, object : Object):
	var dir = DirAccess.open(path)
	dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	var file = dir.get_next()
	while file != "":
		if file.ends_with(".pck"):
			var pack = callable.call(file, const_path, dict, object)
		file = dir.get_next()
	dir.list_dir_end()

func load_character(path : String):
	pass

func load_resource(pack_path, const_path, dict, object) -> Object:
	# This could fail if, for example, mod.pck cannot be found.
	var success = ProjectSettings.load_resource_pack(const_path + pack_path, false)
	if success:
		# Now one can use the assets as if they had them in the project from the start.
		var metadata = load(const_path + pack_path.trim_suffix(".pck") + "/" + "metadata.tscn") #TODO: Define behavior and strcuture
		assert(metadata!= null, "Invalid Resource Pack, metadata not found.")
		object = object.duplicate()
		object.name = metadata.get("name")
		if object is Scenario:
			object.levels = metadata.get("levels")
		elif object is CharacterPack:
			object.char_list = metadata.get("character_list")
		if object != null:
			dict[object.name] = object
		return object
	else:
		print("Failed to load resource pack: " + pack_path)
		return null


func _ready():
	explore_folder("res://maps", load_resource, MAP_PATH, scenarios, Scenario.new())
	explore_folder("res://characters", load_character, CHAR_PATH, characters, CharacterPack.new())

class CharacterPack:
	var name = ""
	var char_list = []
	
	
class Scenario:
	#MISSING: Objects
	#MISSING: Weapons

	var name = ""
	var levels = []
	var bin_levels = {}

	func load_levels():
		for level_i in levels:
			var level = load(level_i) #TODO: This is overly expensive, we should load the levels only when needed
			if level != null:
				bin_levels[level.name] = level

	func get_level(level_name):
		# check if the level is loaded and exists
		if level_name in bin_levels:
			return bin_levels[level_name]
		else:
			return null
			
