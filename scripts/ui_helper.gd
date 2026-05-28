extends Node

static func create_button_style(bg_color: String, radius: int = 12):
	var style = StyleBoxFlat.new()
	style.bg_color = Color(bg_color)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	return style

static func center_control(control: Control, size: Vector2, y_offset: float = 0):
	var screen_size = control.get_viewport_rect().size
	control.size = size
	control.position = Vector2(
		(screen_size.x - size.x) / 2,
		(screen_size.y - size.y) / 2 + y_offset
	)
