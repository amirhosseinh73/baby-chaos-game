extends Node

static func get_object_types():
	return [
		{
			"name": "Toy",
			"texture": preload("res://assets/toy-1.png"),
			"score": 1,
			"chaos_reduce": 3,
			"danger_time": 5.0,
			"chaos_penalty": 4,
			"unlock_score": 0
		},
		{
			"name": "Blocks",
			"texture": preload("res://assets/toy-2.png"),
			"score": 1,
			"chaos_reduce": 3,
			"danger_time": 4.5,
			"chaos_penalty": 5,
			"unlock_score": 0
		},
		{
			"name": "Milk Spill",
			"texture": preload("res://assets/toy-3.png"),
			"score": 2,
			"chaos_reduce": 5,
			"danger_time": 3.5,
			"chaos_penalty": 10,
			"unlock_score": 5
		},
		{
			"name": "Banana Peel",
			"texture": preload("res://assets/toy-4.png"),
			"score": 1,
			"chaos_reduce": 2,
			"danger_time": 3.0,
			"chaos_penalty": 8,
			"unlock_score": 8
		},
		{
			"name": "Wall Drawing",
			"texture": preload("res://assets/toy-5.png"),
			"score": 3,
			"chaos_reduce": 7,
			"danger_time": 4.0,
			"chaos_penalty": 12,
			"unlock_score": 12
		},
		{
			"name": "Big Mess",
			"texture": preload("res://assets/toy-6.png"),
			"score": 4,
			"chaos_reduce": 10,
			"danger_time": 2.8,
			"chaos_penalty": 16,
			"unlock_score": 20
		}
	]
