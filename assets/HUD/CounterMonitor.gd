extends Label


# CounterMonitor.gd -- Label script for displaying a float value, e.g. time countdown


@export var counter_signal_name: String = "" # signal must have signature: time_changed(time_left: float)


func _ready():
	self.connect(counter_signal_name, Callable(self, "counter_changed"))

func counter_changed(counter_value: float):
	self.text = str(snapped(counter_value, 0.1))
