extends Node

static func clear_room(room_layer):
	for child in room_layer.get_children():
		child.queue_free()

static func build_child_room(room_layer):
	clear_room(room_layer)

	var screen_size = room_layer.get_viewport_rect().size

	var wall_height = screen_size.y * 0.42
	var floor_y = wall_height
	var floor_height = screen_size.y - wall_height

	create_rect(room_layer, "Wall", Vector2(0, 0), Vector2(screen_size.x, wall_height), "#8E7CFF")
	create_rect(room_layer, "Floor", Vector2(0, floor_y), Vector2(screen_size.x, floor_height), "#F7C59F")

	create_rect(
		room_layer,
		"Rug",
		Vector2(screen_size.x * 0.22, floor_y + floor_height * 0.30),
		Vector2(screen_size.x * 0.46, floor_height * 0.22),
		"#FFD23F"
	)

	create_rect(
		room_layer,
		"Window",
		Vector2(screen_size.x * 0.62, wall_height * 0.18),
		Vector2(screen_size.x * 0.14, wall_height * 0.28),
		"#BDE0FE"
	)

	create_rect(
		room_layer,
		"ToyBox",
		Vector2(screen_size.x * 0.07, floor_y + floor_height * 0.35),
		Vector2(screen_size.x * 0.12, floor_height * 0.20),
		"#FF6B6B"
	)

static func create_rect(parent, node_name, position, size, color):
	var rect = ColorRect.new()
	rect.name = node_name
	rect.position = position
	rect.size = size
	rect.color = Color(color)
	parent.add_child(rect)
