extends Control

const UIHelper = preload("res://scripts/ui_helper.gd")
const ObjectDatabase = preload("res://scripts/object_database.gd")
const LevelDatabase = preload("res://scripts/level_database.gd")
const RoomBuilder = preload("res://scripts/room_builder.gd")
var toy_scene = preload("res://scenes/toy.tscn")
var room_object_scene = preload("res://scenes/room_object.tscn")
var living_room_scene = preload("res://scenes/living_room.tscn")

const DEFAULT_CHAOS_SPEED = 1.2
const DEFAULT_SPAWN_SPEED = 0.9
const TOY_SIZE = Vector2(64, 64)
const MIN_ACTIVE_ITEMS = 2
const START_ITEMS = 0

var score = 0
var chaos = 0.0
var game_over = false
var chaos_speed = DEFAULT_CHAOS_SPEED
var spawn_speed = DEFAULT_SPAWN_SPEED
var current_level = {}
var level_time_left = 0.0
var level_completed = false
var object_types = []
var cleaned_mess_count = 0
var mess_order = []
var next_mess_index = 0
var is_baby_busy = false
var room_objects = {}
var room_scene_instance = null
var total_messes_created := 0
var last_messed_object := ""

@onready var score_label = $ScoreLabel
@onready var chaos_bar = $ChaosBar
@onready var game_over_label = $GameOverLabel
@onready var spawn_timer = $SpawnTimer
@onready var restart_button = $RestartButton
@onready var menu_panel = $MenuPanel
@onready var play_button = $MenuPanel/PlayButton
@onready var title_label = $MenuPanel/TitleLabel
@onready var level_label = $LevelLabel
@onready var timer_label = $TimerLabel
@onready var level_complete_label = $LevelCompleteLabel
@onready var level_progress_bar = $LevelProgressBar
@onready var room_layer = $RoomLayer
@onready var baby = $Baby
@onready var cleaned_label = $CleanedLabel

func _ready():
	randomize()
	object_types = ObjectDatabase.get_object_types()
	setup_restart_button_style()
	center_game_over_ui()
	baby.mess_created.connect(_on_baby_mess_created)
	show_main_menu()

func start_new_game():
	score = 0
	chaos = 0.0
	game_over = false
	chaos_speed = DEFAULT_CHAOS_SPEED
	spawn_speed = DEFAULT_SPAWN_SPEED

	game_over_label.visible = false
	restart_button.visible = false
	menu_panel.visible = false
	
	total_messes_created = 0
	last_messed_object = ""
	
	current_level = LevelDatabase.get_level_1()
	mess_order = current_level["mess_order"]

	build_room_scene()
	build_level_room_objects()

	level_time_left = current_level["time_limit"]
	level_completed = false

	next_mess_index = 0
	is_baby_busy = false
	cleaned_mess_count = 0

	level_complete_label.visible = false

	update_level_label()
	update_timer_label()
	update_cleaned_label()
	update_level_progress_bar()
	
	restart_button.text = "Restart"

	for toy in get_tree().get_nodes_in_group("toys"):
		toy.queue_free()

	update_score_label()
	update_chaos_bar()

	spawn_timer.stop()
	
	baby.start_baby()
	request_next_mess()

func _process(delta):
	if game_over or level_completed:
		return

	level_time_left -= delta

	if level_time_left <= 0:
		level_time_left = 0
		update_timer_label()
		end_game()
		return

	update_timer_label()

	chaos += chaos_speed * delta
	update_chaos_bar()

	if chaos >= 100:
		end_game()

func update_score_label():
	score_label.text = "Score: " + str(score)

func update_chaos_bar():
	chaos_bar.value = chaos

func end_game():
	game_over = true
	spawn_timer.stop()
	baby.stop_baby()

	for toy in get_tree().get_nodes_in_group("toys"):
		toy.disable_click()

	game_over_label.visible = true
	restart_button.visible = true

	center_game_over_ui()

	game_over_label.move_to_front()
	restart_button.move_to_front()

func is_position_overlapping(new_position):
	var padding = 25
	var new_rect = Rect2(new_position, TOY_SIZE + Vector2(padding, padding))

	for toy in get_tree().get_nodes_in_group("toys"):
		if toy.is_collected:
			continue

		var existing_rect = Rect2(toy.position, TOY_SIZE + Vector2(padding, padding))

		if new_rect.intersects(existing_rect):
			return true

	return false

func update_difficulty():
	chaos_speed = DEFAULT_CHAOS_SPEED + (score * 0.04)
	spawn_speed = max(0.45, DEFAULT_SPAWN_SPEED - (score * 0.01))
	spawn_timer.wait_time = spawn_speed

func setup_restart_button_style():
	restart_button.text = "Restart"

	restart_button.add_theme_stylebox_override("normal", UIHelper.create_button_style("#FF4D4D"))
	restart_button.add_theme_stylebox_override("hover", UIHelper.create_button_style("#FF6B6B"))
	restart_button.add_theme_stylebox_override("pressed", UIHelper.create_button_style("#D93636"))

	restart_button.add_theme_color_override("font_color", Color("#FFFFFF"))
	restart_button.add_theme_font_size_override("font_size", 28)

func _on_restart_button_pressed() -> void:
	start_new_game()
	
func center_game_over_ui():
	UIHelper.center_control(game_over_label, Vector2(400, 70), -90)
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	UIHelper.center_control(restart_button, Vector2(180, 60), 10)

func show_main_menu():
	game_over = true
	menu_panel.visible = true
	game_over_label.visible = false
	restart_button.visible = false
	spawn_timer.stop()
	baby.stop_baby()

	for toy in get_tree().get_nodes_in_group("toys"):
		toy.queue_free()

	setup_menu_style()
	center_menu_ui()

func center_menu_ui():
	UIHelper.center_control(title_label, Vector2(500, 80), -130)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	UIHelper.center_control(play_button, Vector2(180, 60), 0)
	
func setup_menu_style():
	title_label.add_theme_color_override("font_color", Color("#FFFFFF"))
	title_label.add_theme_font_size_override("font_size", 56)

	play_button.add_theme_stylebox_override("normal", UIHelper.create_button_style("#FFD23F"))
	play_button.add_theme_stylebox_override("hover", UIHelper.create_button_style("#FFE066"))
	play_button.add_theme_stylebox_override("pressed", UIHelper.create_button_style("#E6B800"))

	play_button.add_theme_color_override("font_color", Color("#2D2A32"))
	play_button.add_theme_font_size_override("font_size", 32)

func _on_play_button_pressed() -> void:
	menu_panel.visible = false
	start_new_game()

func update_level_label():
	level_label.text = "Level " + str(current_level["id"]) + ": " + current_level["name"]

func update_timer_label():
	timer_label.text = "Time: " + str(ceil(level_time_left))
	
func complete_level():
	level_completed = true
	level_progress_bar.value = 100
	spawn_timer.stop()
	#baby.stop_baby()

	for toy in get_tree().get_nodes_in_group("toys"):
		toy.disable_click()

	level_complete_label.visible = true
	restart_button.visible = true
	restart_button.text = "Replay"

	center_level_complete_ui()

	level_complete_label.move_to_front()
	restart_button.move_to_front()
	
func center_level_complete_ui():
	UIHelper.center_control(level_complete_label, Vector2(500, 70), -90)
	level_complete_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	UIHelper.center_control(restart_button, Vector2(180, 60), 10)
	
func update_level_progress_bar():
	if current_level.is_empty():
		level_progress_bar.value = 0
		return

	var required_count = current_level["required_clean_count"]
	var progress_percent = (float(cleaned_mess_count) / float(required_count)) * 100.0

	level_progress_bar.value = progress_percent

func _on_baby_mess_created(mess_position, object_name, object_id):
	if game_over or level_completed:
		return

	is_baby_busy = false

	await throw_room_object_to_mess(object_id, mess_position)

	await get_tree().create_timer(get_next_mess_delay()).timeout

	request_next_mess()
	
func update_cleaned_label():
	cleaned_label.text = "Cleaned: " + str(cleaned_mess_count) + "/" + str(current_level["required_clean_count"])

func request_next_mess():

	if game_over or level_completed:
		return

	if is_baby_busy:
		return

	if total_messes_created >= current_level["required_clean_count"]:
		baby.start_dancing()
		return

	if get_active_mess_count() >= current_level["max_active_messes"]:
		return

	var object_name := ""

	if total_messes_created < current_level["mess_order"].size():

		object_name = current_level["mess_order"][total_messes_created]

	else:

		var candidates = []

		for name in current_level["mess_order"]:

			if name == last_messed_object:
				continue

			if is_object_currently_messed(name):
				continue

			candidates.append(name)

		if candidates.is_empty():
			return

		object_name = candidates.pick_random()

	last_messed_object = object_name

	var mess_data = null

	for item in current_level["mess_objects"]:

		if item["object"] == object_name:
			mess_data = item
			break

	if mess_data == null:
		return

	is_baby_busy = true

	var baby_node = room_scene_instance.get_node(
		"RoomBabyPreview/" +
		mess_data["baby_node"]
	)

	var mess_node = room_scene_instance.get_node(
		"RoomToysMessPreview/" +
		mess_data["mess_node"]
	)

	baby.perform_mess_at(
		baby_node.position,
		object_name,
		mess_node.position,
		mess_data["id"]
	)

	total_messes_created += 1

func get_object_data_by_name(object_name):
	for object_data in object_types:
		if object_data["name"] == object_name:
			return object_data

	return object_types[0]

func get_active_mess_count():
	var count = 0

	for obj in room_objects.values():
		if obj.is_mess:
			count += 1

	return count

func get_next_mess_delay():
	var active_count = get_active_mess_count()

	if active_count == 0:
		return 0.15

	if active_count == 1:
		return 0.45

	if active_count == 2:
		return 0.9

	return 1.4

func build_level_room_objects():

	room_objects.clear()

	for mess_data in current_level["mess_objects"]:

		var object_id = mess_data["id"]

		var object_data = get_object_data_by_name(
			mess_data["object"]
		)

		var room_object = room_object_scene.instantiate()

		room_object.setup(
			mess_data,
			object_data["texture"]
		)

		room_object.cleaned.connect(
			_on_room_object_cleaned
		)

		var source_sprite = room_scene_instance.get_node(
			"RoomToysSource/" +
			mess_data["source_node"]
		)

		room_object.position = source_sprite.position
		room_object.rotation = source_sprite.rotation
		room_object.scale = source_sprite.scale
		
		room_object.original_position = source_sprite.position
		room_object.original_rotation = source_sprite.rotation
		room_object.original_scale = source_sprite.scale

		room_scene_instance.add_child(room_object)

		room_objects[object_id] = room_object

func throw_room_object_to_mess(object_id, mess_position):

	if not room_objects.has(object_id):
		return

	var room_object = room_objects[object_id]

	var mess_data = null

	for item in current_level["mess_objects"]:

		if item["id"] == object_id:
			mess_data = item
			break

	if mess_data == null:
		return

	var mess_node = room_scene_instance.get_node(
		"RoomToysMessPreview/" +
		mess_data["mess_node"]
	)

	var tween = create_tween()

	tween.parallel().tween_property(
		room_object,
		"position",
		mess_node.position,
		0.25
	)

	tween.parallel().tween_property(
		room_object,
		"rotation",
		mess_node.rotation,
		0.25
	)

	tween.parallel().tween_property(
		room_object,
		"scale",
		mess_node.scale,
		0.25
	)

	await tween.finished

	room_object.is_mess = true

func build_room_scene():
	for child in room_layer.get_children():
		child.queue_free()

	room_scene_instance = living_room_scene.instantiate()

	room_layer.add_child(room_scene_instance)

func _on_room_object_cleaned(object_id):

	if not room_objects.has(object_id):
		return

	var obj = room_objects[object_id]

	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		obj,
		"position",
		obj.original_position,
		0.35
	)

	tween.tween_property(
		obj,
		"rotation",
		obj.original_rotation,
		0.35
	)

	tween.tween_property(
		obj,
		"scale",
		obj.original_scale,
		0.35
	)

	await tween.finished

	obj.is_mess = false

	score += 1
	cleaned_mess_count += 1

	update_score_label()
	update_cleaned_label()
	update_level_progress_bar()
	
	if cleaned_mess_count >= current_level["required_clean_count"]:
		complete_level()
		return

	request_next_mess()

func is_object_currently_messed(object_name:String) -> bool:

	for obj in room_objects.values():

		if obj.object_name == object_name and obj.is_mess:
			return true

	return false
