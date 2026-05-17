extends TextureRect

signal collected(toy, score_value, chaos_reduce)
signal danger_triggered(toy, chaos_penalty)

const TOY_SIZE = Vector2(96, 96)

var object_data = {}
var is_collected = false
var danger_already_triggered = false
var lifetime = 4.0

func setup(data):
	object_data = data

func _ready():
	add_to_group("toys")

	if object_data.is_empty():
		object_data = {
			"name": "Toy",
			"texture": preload("res://assets/toy-1.png"),
			"score": 1,
			"chaos_reduce": 3,
			"danger_time": 5.0,
			"chaos_penalty": 5
		}

	texture = object_data["texture"]
	size = TOY_SIZE
	pivot_offset = size / 2
	mouse_filter = Control.MOUSE_FILTER_STOP

	lifetime = object_data["danger_time"]

	scale = Vector2(0.2, 0.2)
	modulate = Color("#FFFFFF")

	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.12)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.08)

func _process(delta):
	if is_collected:
		return

	if danger_already_triggered:
		return

	lifetime -= delta

	if lifetime <= 0:
		danger_already_triggered = true
		danger_triggered.emit(self, object_data["chaos_penalty"])
		play_danger_animation()

func _gui_input(event):
	if is_collected:
		return

	if event is InputEventMouseButton and event.pressed:
		is_collected = true
		mouse_filter = Control.MOUSE_FILTER_IGNORE

		collected.emit(
			self,
			object_data["score"],
			object_data["chaos_reduce"]
		)

		var tween = create_tween()
		tween.parallel().tween_property(self, "scale", Vector2(0.0, 0.0), 0.15)
		tween.parallel().tween_property(self, "modulate:a", 0.0, 0.15)

		await tween.finished
		queue_free()

func play_danger_animation():
	modulate = Color("#FF6B6B")

	var tween = create_tween()
	tween.set_loops(3)
	tween.tween_property(self, "rotation_degrees", 8, 0.06)
	tween.tween_property(self, "rotation_degrees", -8, 0.06)
	tween.tween_property(self, "rotation_degrees", 0, 0.06)

func disable_click():
	is_collected = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
