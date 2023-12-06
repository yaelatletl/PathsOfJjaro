extends Label
class_name FloatCounter


# CounterMonitor.gd -- Label script for displaying a float value, rounded to 1DP; set the `VALUE_CHANGED(float)` signal name in the node's Inspector


@export var counter_signal_name: String = "" # signal must have signature: time_changed(time_left: float)


func _ready():
	self.connect(counter_signal_name, Callable(self, "counter_changed"))

func counter_changed(value: float):
	self.text = str(snapped(value, 0.1))
