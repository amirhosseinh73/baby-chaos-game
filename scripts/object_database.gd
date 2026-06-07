extends Node

static func get_object_types():
	return [
		{
			"name": "Duck",
			"texture": preload("res://assets/toys/toy-duck.png"),

			"source_transform": {
				"rotation": 0.0,
				"scale": Vector2(0.408, 0.408)
			},

			"mess_transform": {
				"rotation": 70,
				"scale": Vector2(0.408, 0.408)
			},

			"score": 1,
			"chaos_reduce": 3,
			"danger_time": 5.0,
			"chaos_penalty": 4,
			"unlock_score": 0
		},
		{
			"name": "FlowerPot",
			"texture": preload("res://assets/rooms/living-room/flower-pot-1.png"),
			
			"source_transform": {
				"rotation": 0.0,
				"scale": Vector2(0.192, 0.192)
			},

			"mess_transform": {
				"rotation": 65.0,
				"scale": Vector2(0.192, 0.192)
			},
			
			"score": 1,
			"chaos_reduce": 3,
			"danger_time": 5.0,
			"chaos_penalty": 4,
			"unlock_score": 0
		},
		{
			"name": "TeddyBear",
			"texture": preload("res://assets/toys/toy-teddy-bear.png"),
			
			"source_transform": {
				"rotation": 0.0,
				"scale": Vector2(0.705, 0.705)
			},

			"mess_transform": {
				"rotation": -71,
				"scale": Vector2(0.705, 0.705)
			},
			
			"score": 1,
			"chaos_reduce": 3,
			"danger_time": 5.0,
			"chaos_penalty": 4,
			"unlock_score": 0
		},
		{
			"name": "Scooter",
			"texture": preload("res://assets/toys/toy-scooter.png"),
			
			"source_transform": {
				"rotation": 0.0,
				"scale": Vector2(0.71, 0.71)
			},

			"mess_transform": {
				"rotation": -35.0,
				"scale": Vector2(0.71, 0.71)
			},

			"score": 1,
			"chaos_reduce": 3,
			"danger_time": 5.0,
			"chaos_penalty": 4,
			"unlock_score": 0
		},
		{
			"name": "Guitar",
			"texture": preload("res://assets/toys/toy-guitar.png"),
			
			"source_transform": {
				"rotation": 0.0,
				"scale": Vector2(0.669, 0.767)
			},

			"mess_transform": {
				"rotation": -140.0,
				"scale": Vector2(0.669, 0.767)
			},
			
			"score": 1,
			"chaos_reduce": 3,
			"danger_time": 5.0,
			"chaos_penalty": 4,
			"unlock_score": 0
		},
		{
			"name": "Bucket",
			"texture": preload("res://assets/toys/toy-bucket.png"),
			
			"source_transform": {
				"rotation": 37,
				"scale": Vector2(1, 1)
			},

			"mess_transform": {
				"rotation": 100,
				"scale": Vector2(1, 1)
			},
			
			"score": 1,
			"chaos_reduce": 3,
			"danger_time": 5.0,
			"chaos_penalty": 4,
			"unlock_score": 0
		},
		{
			"name": "Crown",
			"texture": preload("res://assets/toys/toy-crown.png"),
			
			"source_transform": {
				"rotation": 0.0,
				"scale": Vector2(0.25, 0.25)
			},

			"mess_transform": {
				"rotation": -65,
				"scale": Vector2(0.25, 0.25)
			},

			"score": 1,
			"chaos_reduce": 3,
			"danger_time": 5.0,
			"chaos_penalty": 4,
			"unlock_score": 0
		}
	]
