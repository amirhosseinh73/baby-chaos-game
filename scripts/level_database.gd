extends Node

static func get_level_1():
	return {
		"id": 1,
		"name": "Toy Chaos",
		"room": "child_room",
		"parent": "mom",
		"time_limit": 45.0,
		"max_items": 10,
		"max_active_messes": 3,
		"required_clean_count": 10,
		"allowed_objects": ["Toy", "Blocks"],
		"mess_sequence": [
			{ "object": "Toy", "position": Vector2(0.20, 0.76) },
			{ "object": "Blocks", "position": Vector2(0.55, 0.74) },
			{ "object": "Toy", "position": Vector2(0.78, 0.78) },
			{ "object": "Blocks", "position": Vector2(0.32, 0.66) },
			{ "object": "Toy", "position": Vector2(0.63, 0.82) },
			{ "object": "Blocks", "position": Vector2(0.15, 0.84) },
			{ "object": "Toy", "position": Vector2(0.85, 0.70) },
			{ "object": "Blocks", "position": Vector2(0.45, 0.86) },
			{ "object": "Toy", "position": Vector2(0.70, 0.64) },
			{ "object": "Blocks", "position": Vector2(0.25, 0.72) }
		]
	}
