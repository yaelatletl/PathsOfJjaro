tool
extends Container
class_name CircularContainer

export(float) var spread_anlge = 15
export(float) var floaters_scale = 1.0
func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		# Must re-sort the children
		var children = get_children()
		var div_size = children.size()-1
		var new_size = Vector2(min(rect_size.x, rect_size.y), min(rect_size.x, rect_size.y))
		var rect_vec = 2*Vector2(max(rect_size.x, rect_size.y), max(rect_size.x, rect_size.y))/5
		rect_vec = rect_vec.rotated(deg2rad(-45))
		fit_child_in_rect( children[0], Rect2( Vector2(), new_size) )
		children.remove(0)
		for c in children:
		# Fit to 
			rect_vec = rect_vec.rotated(deg2rad(spread_anlge))
			fit_child_in_rect( c, Rect2( rect_vec, (floaters_scale*new_size)/div_size) )
func set_some_setting():
    # Some setting changed, ask for children re-sort
    queue_sort()