extends Node
class_name AmmoPickup

onready var area : Area = $PickupArea
export(String) var weapon_name = ""
export(int) var ammo = 0
export(bool) var oneshot = true

func _ready() -> void:
	var err = area.connect("body_entered", self, "_on_area_body_entered")
	if err!=OK:
		printerr("Connection on ammo pickup failed. Error code: ", err)

func _on_area_body_entered(body) -> void:
	if body.has_method("_get_component"):
		var wep = body._get_component("weapons")
		if wep:
			wep.add_ammo(weapon_name, ammo)
			if oneshot:
				Gamestate.remove_node(self)