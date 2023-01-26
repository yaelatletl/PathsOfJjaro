extends Node

CONST MAP_PATH = "res://maps/"

var scenarios = {}
# Have them as a dict, we access by scenario name all the levels in the scenario

var current_scenario = 0

#we load all pck files in the directory "maps" and we create a list of all the maps in the package

func explore_scenarios():
	var dir = Directory.new()
	dir.open("res://maps")
	dir.list_dir_begin()
	var file = dir.get_next()
	while file != "":
		if file.ends_with(".pck"):
			var scenario = load_scenario(file)
			if scenario != null:
				scenarios[scenario.name] = scenario
		file = dir.get_next()
	dir.list_dir_end()


func load_scenario(scenario_path) -> Scenario:
    # This could fail if, for example, mod.pck cannot be found.
    var success = ProjectSettings.load_resource_pack(MAP_PATH + scenario_path, false)
    if success:
        # Now one can use the assets as if they had them in the project from the start.
        var metadata = load(MAP_PATH + scenario_path.trim_suffix(".pck") + "/" + "metadata.tscn")
		var scenario = Scenario.new()
		scenario.name = metadata.get("name")
		scenario.levels = metadata.get("levels")
		return scenario
	else:
		print("Failed to load resource pack: " + scenario_path)
		return null


func _ready():
	explore_scenarios()

class Scenario:
	var levels = []
	var bin_levels = {}

	func load_levels():
		for level in levels:
			var level = load(level)
			if level != null:
				bin_levels[level.name] = level

	func get_level(level_name):
		# check if the level is loaded and exists
		if level_name in bin_levels:
			return bin_levels[level_name]
		else:
			return null
			