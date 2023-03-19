extends InteractableGeneric
@export var one_shot: bool = true #Set this to false to achieve an "armory" asset
@export var weapon_archetype = "" # (String, FILE, "*.json")
@export var view_model: PackedScene = null

func _ready() -> void:
	message = "Press E to pick up the " + name

func interaction_triggered(interactor_body : Node3D) -> void:
	print("Interacting with " + name)
	if interactor_body.has_method("_get_component"):
		if interactor_body._get_component("weapons"):
			var weapon = interactor_body._get_component("weapons")
			weapon.add_weapon(name, weapon_archetype, view_model)
		if one_shot:
			Gamestate.remove_node(self)
