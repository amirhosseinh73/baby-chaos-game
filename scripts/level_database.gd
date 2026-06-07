extends Node

static func get_level_1():
	return {
		"id": 1,
		"name": "Living Room Chaos",
		"room": "living_room",
		"parent": "mom",
		"time_limit": 45.0,
		"max_items": 10,
		"max_active_messes": 3,
		"required_clean_count": 10,

		"mess_order": [
			"Duck",
			"FlowerPot",
			"TeddyBear",
			"Guitar",
			"Scooter",
			"Bucket",
			"Crown"
		],

		"mess_objects": [
			{
				"id": "duck_1",
				"object": "Duck",
				"source_position": Vector2(227, 343),
				"baby_position": Vector2(-1400, 700),
				"mess_position": Vector2(296, 576)
			},
			{
				"id": "flowerpot_1",
				"object": "FlowerPot",
				"source_position": Vector2(480, 211),
				"baby_position": Vector2(-350, 450),
				"mess_position": Vector2(539, 231)
			},
			{
				"id": "teddy_1",
				"object": "TeddyBear",
				"source_position": Vector2(880, 440),
				"baby_position": Vector2(1100, 850),
				"mess_position": Vector2(696, 568)
			},
			{
				"id": "scooter_1",
				"object": "Scooter",
				"source_position": Vector2(134, 513),
				"baby_position": Vector2(-1750, 950),
				"mess_position": Vector2(120, 576)
			},
			{
				"id": "guitar_1",
				"object": "Guitar",
				"source_position": Vector2(408, 424),
				"baby_position": Vector2(-700, 850),
				"mess_position": Vector2(368, 512)
			},
			{
				"id": "bucket_1",
				"object": "Bucket",
				"source_position": Vector2(1016, 584),
				"baby_position": Vector2(1500, 950),
				"mess_position": Vector2(1072, 584)
			},
			{
				"id": "crown_1",
				"object": "Crown",
				"source_position": Vector2(714, 277),
				"baby_position": Vector2(550, 450),
				"mess_position": Vector2(536, 536)
			}
		]
	}
