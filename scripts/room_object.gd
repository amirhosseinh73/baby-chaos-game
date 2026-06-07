extends Node2D

signal cleaned(object_id)

var object_id = ""
var object_name = ""
var is_mess = false

var original_position = Vector2.ZERO
var original_rotation = 0.0
var original_scale = Vector2.ONE

func setup(data, texture):

	object_id = data["id"]
	object_name = data["object"]

	$Sprite2D.texture = texture


func _input(event):

	if not is_mess:
		return

	if not event is InputEventMouseButton:
		return

	if not event.pressed:
		return

	var sprite = $Sprite2D

	if sprite.texture == null:
		return

	var local_pos = to_local(event.position)

	var rect = Rect2(
		-sprite.texture.get_size() / 2,
		sprite.texture.get_size()
	)

	if rect.has_point(local_pos):
		cleaned.emit(object_id)
