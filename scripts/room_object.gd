extends Node2D

signal cleaned(object_id)

@onready var sprite = $Sprite2D

var object_id = ""
var object_name = ""
var source_position = Vector2.ZERO
var baby_position = Vector2.ZERO
var mess_position = Vector2.ZERO
var is_mess = false
var original_position = Vector2.ZERO
var original_rotation = 0.0
var original_scale = Vector2.ONE

func setup(data, texture):

	object_id = data["id"]
	object_name = data["object"]

	source_position = data["source_position"]
	baby_position = data["baby_position"]
	mess_position = data["mess_position"]

	sprite.texture = texture

	original_position = source_position

func _gui_input(event):
	if not is_mess:
		return

	if event is InputEventMouseButton and event.pressed:
		cleaned.emit(object_id)
