extends Node

const WALL = preload("res://assets/rooms/living-room/wall.png")
const FLOOR = preload("res://assets/rooms/living-room/floor.png")
const WINDOW = preload("res://assets/rooms/living-room/window-2.png")
const COUCH = preload("res://assets/rooms/living-room/couch-2.png")
const SHELF = preload("res://assets/rooms/living-room/shelf-1.png")
const RUG = preload("res://assets/rooms/living-room/rug-5.png")
const PLANT = preload("res://assets/rooms/living-room/flower-pot-2.png")
const LAMP = preload("res://assets/rooms/living-room/lamp.png")
const CLOCK = preload("res://assets/rooms/living-room/clock-wall-2.png")
const FRAME_1 = preload("res://assets/rooms/living-room/frame-1.png")
const FRAME_2 = preload("res://assets/rooms/living-room/frame-2.png")

static func clear_room(room_layer):
	for child in room_layer.get_children():
		child.queue_free()

static func build_room(room_layer, room_type):
	clear_room(room_layer)

	match room_type:
		"living_room":
			build_living_room(room_layer)
		_:
			build_living_room(room_layer)

static func build_living_room(room_layer):
	var screen_size = room_layer.get_viewport_rect().size
	var wall_height = screen_size.y * 0.46
	var floor_y = wall_height
	var floor_height = screen_size.y - wall_height

	create_full_texture(room_layer, "Wall", WALL, Vector2(0, 0), Vector2(screen_size.x, wall_height), 0)
	create_full_texture(room_layer, "Floor", FLOOR, Vector2(0, floor_y), Vector2(screen_size.x, floor_height), 1)

	create_image_by_width(room_layer, "Window", WINDOW, Vector2(0.52, 0.22), 0.30, 2)

	create_image_by_width(room_layer, "Frame1", FRAME_1, Vector2(0.18, 0.18), 0.08, 3)
	create_image_by_width(room_layer, "Frame2", FRAME_2, Vector2(0.29, 0.18), 0.08, 3)

	create_image_by_width(room_layer, "Clock", CLOCK, Vector2(0.82, 0.18), 0.06, 3)

	create_image_by_width(room_layer, "Couch", COUCH, Vector2(0.58, 0.58), 0.38, 5)

	create_image_by_width(room_layer, "Rug", RUG, Vector2(0.50, 0.82), 0.48, 2)

	create_image_by_width(room_layer, "Shelf", SHELF, Vector2(0.84, 0.56), 0.15, 5)

	create_image_by_width(room_layer, "PlantLeft", PLANT, Vector2(0.10, 0.67), 0.07, 4)

	create_image_by_width(room_layer, "Lamp", LAMP, Vector2(0.94, 0.54), 0.06, 4)

static func create_full_texture(parent, node_name, texture, position, size, z_index):
	var rect = TextureRect.new()
	rect.name = node_name
	rect.texture = texture
	rect.position = position
	rect.size = size
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.z_index = z_index
	parent.add_child(rect)
	return rect

static func create_image_by_width(parent, node_name, texture, center_percent, width_percent, z_index):
	var screen_size = parent.get_viewport_rect().size
	var texture_size = texture.get_size()

	var target_width = screen_size.x * width_percent
	var target_height = target_width * (texture_size.y / texture_size.x)

	var rect = TextureRect.new()
	rect.name = node_name
	rect.texture = texture
	rect.size = Vector2(target_width, target_height)
	rect.position = Vector2(
		screen_size.x * center_percent.x - target_width / 2,
		screen_size.y * center_percent.y - target_height / 2
	)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.z_index = z_index
	parent.add_child(rect)
	return rect
