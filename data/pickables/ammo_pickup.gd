extends Node
class_name AmmoPickup

@onready var area : Area3D = $PickupArea
@export var weapon_name: String = ""
@export var ammo: int = 0
@export var one_shot: bool = true

func _ready() -> void:
	var err = area.connect("body_entered",Callable(self,"_on_area_body_entered"))
	if err!=OK:
		printerr("Connection checked ammo pickup failed. Error code: ", err)

func _on_area_body_entered(body) -> void:
	if body.has_method("_get_component"):
		var wep = body._get_component("weapons")
		if wep:
			wep.add_ammo(weapon_name, ammo)
			if one_shot:
				Gamestate.remove_node(self)