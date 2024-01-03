extends Container


# Radar.gd


# TODO: implement; Q. should radar track active NPCs on all levels (same as in Classic)?
#
# if so, should it use an Elite-style radar display where the circle (xz plane) is tilted and each NPC indicates its height (y-offset) above/below that plane? we should definitely try this: it's trivial to code and it'll tie in well with the improved automap display that reduces alpha on floors above and below the player's current floor (to reduce visual noise and user confusion, particularly when floors overlap)
#
# alternatively, we could use the enhanced automap's knowledge of each level's topography to omit NPCs on other levels unless the path to those levels (stairs, elevator, ladder, duct, etc) lies inside the radar radius (i.e. radar should show imminent threats; the one exception being Bobs as player should see their locations at all times, same as in Classic; Q. how should MADDs display on radar/automap?)


@export var spread_angle: float = 15
@export var floaters_scale: float = 1.0


func _notification(what):
	return
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
