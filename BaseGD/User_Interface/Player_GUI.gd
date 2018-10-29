tool
extends Control

export(float) var rotary_min_angle = -180 setget set_rotary_min_angle
export(float) var rotary_max_angle = 135.0 setget set_rotary_max_angle
export(float) var radius = 85.0 setget set_radius

const REFERENCE_WIDTH = 225

const ROTARY_BASE_WIDTH = 25.0

var rotary_width = 25.0

export (float, 0, 1) var indicator_value = 0.0 setget set_indicator_value

export(float) var indicator_line = 0.75
export(float) var indicator_line_width = 2.0
export(Color) var fill_post_line_color = Color(0.0,0.0,0.0,1.0)
export(Color) var base_post_line_color = Color(0.0,0.0,0.0,0.25)
export(Color) var fill_color = Color(1.0, 1.0, 1.0) setget set_fill_color

func set_fill_color(value):
	fill_color = value
	update()

func set_indicator_value(value):
	indicator_value = value
	update()

func set_radius(value):
	radius = value
	update()

func set_rotary_max_angle(value):
	rotary_max_angle = value
	update()
	
func set_rotary_min_angle(value):
	rotary_max_angle = value
	update()

func draw_circle_arc(center, radius, angle_from, angle_to, width, color, post_line_color=fill_post_line_color):
	var total_degrees = angle_to-angle_from
	var post_line = indicator_line
	var nb_points = int((total_degrees/270)*1000) # Subdivision of the Circular Arc / Lowest Decimal point for below 0.02 for health and oxygen
	var points_arc = PoolVector2Array()
	var post_line_points = PoolVector2Array()
	if nb_points > 0:
		for i in range(nb_points+1):
			var angle_point = angle_from + i * (angle_to-angle_from) / nb_points - 90
			if deg2completion(angle_point+90) >= post_line and post_line != -1:
				post_line_points.push_back(anglepoint2pos(center, angle_point, radius))
			else:
				points_arc.push_back(anglepoint2pos(center, angle_point, radius))
		if deg2completion(angle_to) >= post_line and post_line != -1:
			# ensure that the last and first point of the two indicator segments are always at
			# the middle of the orgasm line, this avoids some weird artifacting we had before
			var final_post_line_array = PoolVector2Array()
			var rotary_line_angle = indicator_line*(rotary_max_angle-rotary_min_angle)
			rotary_line_angle = rotary_min_angle + rotary_line_angle
			var common_point = anglepoint2pos(center, rotary_line_angle-90, radius)
			final_post_line_array.append(common_point)
			#final_post_line_array.append(Vector2(0,0))
			final_post_line_array.append_array(post_line_points)
			points_arc.push_back(common_point)
			points_arc.push_back(common_point)
			points_arc.push_back(common_point)
			draw_polyline(final_post_line_array, post_line_color, width, true)
			
		draw_polyline(points_arc, color, width, true)
		print(points_arc.size())
		
func anglepoint2pos(center, angle_point, radius):
	return center + Vector2(cos(deg2rad(angle_point)), sin(deg2rad(angle_point))) * radius


func _draw():
	rotary_width = (ROTARY_BASE_WIDTH/REFERENCE_WIDTH)*rect_size.x
	draw_rotary_indicator((radius/REFERENCE_WIDTH)*rect_size.x, indicator_value, rotary_width)
	draw_rotary_line((radius/REFERENCE_WIDTH)*rect_size.x, 0.75, rotary_width)
func deg2completion(completion_angle):
	var total_degrees = rotary_max_angle-rotary_min_angle
	completion_angle = completion_angle-rotary_min_angle
	return completion_angle / total_degrees

func draw_rotary_indicator(radius, completion, width, draw_base=true):
	var completion_angle = completion*(rotary_max_angle-rotary_min_angle)
	completion_angle = rotary_min_angle + completion_angle
	# Draws the base
	if draw_base:
		draw_circle_arc(rect_size/2, radius, rotary_min_angle, rotary_max_angle, width, Color(0,0,0, 0.5), base_post_line_color)
	# Draws the completed part
	draw_circle_arc(rect_size/2, radius, rotary_min_angle, completion_angle, width, fill_color)
	
func draw_rotary_line(radius, completion, width):
	var completion_angle = completion*(rotary_max_angle-rotary_min_angle)
	completion_angle = rotary_min_angle + completion_angle
	
	var angle_point = deg2rad(completion_angle - 50)
	
	var position_start = rect_size/2 + Vector2(cos(angle_point), sin(angle_point)) * (radius-rotary_width/2)
	var position_end = rect_size/2 + Vector2(cos(angle_point), sin(angle_point)) * (radius+rotary_width/2+4)

	#draw_line(position_start, position_end, Color(1.0,1.0,1.0), 4.0)