extends Label

export(NodePath) var counter_node_path = ""
export(String) var counter_signal_name = ""

onready var counter_node = get_node(counter_node_path)

func _ready():
	counter_node.connect(counter_signal_name, self, "_on_counter_signal")

func _on_counter_signal(counter_value: float):
	text = str(stepify(counter_value, 0.1))
