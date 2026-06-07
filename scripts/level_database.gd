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

				"source_node": "ToyDuck",
				"baby_node": "BabyDuck",
				"mess_node": "ToyDuckMess"
			},
			{
				"id": "flowerpot_1",
				"object": "FlowerPot",

				"source_node": "FlowerPot1",
				"baby_node": "BabyFlowerPot",
				"mess_node": "FlowerPotMess"
			},
			{
				"id": "teddy_1",
				"object": "TeddyBear",

				"source_node": "ToyTeddyBear",
				"baby_node": "BabyTeddy",
				"mess_node": "ToyTeddyBearMess"
			},
			{
				"id": "scooter_1",
				"object": "Scooter",

				"source_node": "ToyScooter",
				"baby_node": "BabyScooter",
				"mess_node": "ToyScooterMess"
			},
			{
				"id": "guitar_1",
				"object": "Guitar",

				"source_node": "ToyGuitar",
				"baby_node": "BabyGuitar",
				"mess_node": "ToyGuitarMess"
			},
			{
				"id": "bucket_1",
				"object": "Bucket",

				"source_node": "ToyBucket",
				"baby_node": "BabyBucket",
				"mess_node": "ToyBucketMess"
			},
			{
				"id": "crown_1",
				"object": "Crown",

				"source_node": "ToyCrown",
				"baby_node": "BabyCrown",
				"mess_node": "ToyCrownMess"
			}
		]
	}
