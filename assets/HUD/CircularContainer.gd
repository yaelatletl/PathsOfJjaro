extends Container


# CircularContainer.gd


@export var spread_angle: float = 15
@export var floaters_scale: float = 1.0


func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		# Must re-sort the children
		var children = get_children()
		var div_size = children.size()-1
		var new_size = Vector2(min(size.x, size.y), min(size.x, size.y))
		var rect_vec = 2*Vector2(max(size.x, size.y), max(size.x, size.y))/5
		rect_vec = rect_vec.rotated(deg_to_rad(-45))
		fit_child_in_rect( children[0], Rect2( Vector2(), new_size) )
		children.remove_at(0)
		for c in children:
			rect_vec = rect_vec.rotated(deg_to_rad(spread_angle))
			fit_child_in_rect( c, Rect2( rect_vec, (floaters_scale * new_size) / div_size) )


func set_some_setting():
	# Some setting changed, ask for children re-sort
	queue_sort()
