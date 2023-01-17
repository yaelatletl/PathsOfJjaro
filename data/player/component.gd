extends Node
class_name Component

enum CHARGE_TYPE{
	SELF_MANAGE,
	USE_MANAGER,
	USE_CHARGE_POINT,
	SPECIAL
}

export(bool) var enabled : bool = true
export(String) var _component_name = ""
export(PackedScene) var ui_scene = null
export(NodePath) var ui_container = ""

onready var actor : Node = get_parent()
onready var ui_root : Node = get_node_or_null(ui_container)

var charge_meter : Node = null

var charging_var : float = 0
var charging_time : float = 0
var charging_max : float = 0
var timer_charge : SceneTreeTimer = null

var charge_type : int = CHARGE_TYPE.SELF_MANAGE

signal charging_changed(charge)

func setup_charge(max_charge : float):
	charging_max = max_charge


func _ready() -> void:
	_start()
	actor._register_component(_component_name, self)
	if ui_root != null:
		charge_meter = ui_scene.instance()
		ui_root.add_child(charge_meter)

func _functional_routine(input : Dictionary) -> void:
	pass

func _start():
	pass

func get_key(input : Dictionary, key : String) -> float:
	if input.has(key):
		return input[key]
	else:
		return 0.0
