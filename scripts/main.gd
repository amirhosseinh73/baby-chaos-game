extends Control

const UIHelper = preload("res://scripts/ui_helper.gd")
const ObjectDatabase = preload("res://scripts/object_database.gd")
const LevelDatabase = preload("res://scripts/level_database.gd")
const RoomBuilder = preload("res://scripts/room_builder.gd")
var toy_scene = preload("res://scenes/toy.tscn")

const DEFAULT_CHAOS_SPEED = 1.2
const DEFAULT_SPAWN_SPEED = 0.9
const TOY_SIZE = Vector2(96, 96)
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
var mess_sequence = []
var next_mess_index = 0
var is_baby_busy = false

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
	RoomBuilder.build_child_room(room_layer)
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
	
	current_level = LevelDatabase.get_level_1()
	level_time_left = current_level["time_limit"]
	level_completed = false
	
	mess_sequence = current_level["mess_sequence"]
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

	spawn_timer.wait_time = spawn_speed
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

func spawn_toy():
	if game_over:
		return
		
	if level_completed:
		return

	if get_tree().get_nodes_in_group("toys").size() >= current_level["max_items"]:
		return

	var object_data = get_random_object_data()

	var toy = toy_scene.instantiate()
	toy.setup(object_data)
	toy.position = get_random_toy_position()

	add_child(toy)

	toy.collected.connect(_on_toy_collected)
	toy.danger_triggered.connect(_on_toy_danger_triggered)

func _on_toy_collected(toy, score_value, chaos_reduce):
	if game_over or level_completed:
		return

	score += score_value
	cleaned_mess_count += 1

	chaos -= chaos_reduce

	if chaos < 0:
		chaos = 0

	update_score_label()
	update_chaos_bar()
	update_cleaned_label()
	update_level_progress_bar()
	update_difficulty()

	if cleaned_mess_count >= current_level["required_clean_count"]:
		complete_level()
		return

	request_next_mess()

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

func _on_spawn_timer_timeout():
	#spawn_toy()
	pass
	

func get_random_toy_position():
	var screen_size = get_viewport_rect().size

	for i in range(20):
		var floor_start_y = screen_size.y * 0.42
		var x = randf_range(50, screen_size.x - TOY_SIZE.x - 50)
		var y = randf_range(floor_start_y + 40, screen_size.y - TOY_SIZE.y - 50)
		var position = Vector2(x, y)

		if not is_position_overlapping(position):
			return position

	var floor_start_y = screen_size.y * 0.42
	var x = randf_range(50, screen_size.x - TOY_SIZE.x - 50)
	var y = randf_range(floor_start_y + 40, screen_size.y - TOY_SIZE.y - 50)
	return Vector2(x, y)

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

func _on_toy_danger_triggered(toy, chaos_penalty):
	if game_over:
		return

	chaos += chaos_penalty

	if chaos > 100:
		chaos = 100

	update_chaos_bar()

	if chaos >= 100:
		end_game()
		
func get_random_object_data():
	var available_objects = []

	for object_data in object_types:
		var is_unlocked = score >= object_data["unlock_score"]
		var is_allowed_in_level = current_level["allowed_objects"].has(object_data["name"])

		if is_unlocked and is_allowed_in_level:
			available_objects.append(object_data)

	return available_objects.pick_random()

func update_level_label():
	level_label.text = "Level " + str(current_level["id"]) + ": " + current_level["name"]

func update_timer_label():
	timer_label.text = "Time: " + str(ceil(level_time_left))
	
func complete_level():
	level_completed = true
	level_progress_bar.value = 100
	spawn_timer.stop()
	baby.stop_baby()

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

func ensure_minimum_items():
	if game_over or level_completed:
		return

	var active_items = get_tree().get_nodes_in_group("toys").size()

	if active_items < MIN_ACTIVE_ITEMS:
		var missing_items = MIN_ACTIVE_ITEMS - active_items

		for i in range(missing_items):
			spawn_toy()

func _on_baby_mess_created(baby_position, object_name):
	if game_over or level_completed:
		return

	is_baby_busy = false

	spawn_specific_object_near_position(object_name, baby_position)

	await get_tree().create_timer(get_next_mess_delay()).timeout

	request_next_mess()
	
func spawn_toy_near_position(spawn_position):

	if get_tree().get_nodes_in_group("toys").size() >= current_level["max_items"]:
		return

	var object_data = get_random_object_data()

	var toy = toy_scene.instantiate()

	toy.setup(object_data)

	var random_offset = Vector2(
		randf_range(-90, 90),
		randf_range(-50, 50)
	)

	toy.position = spawn_position + random_offset

	add_child(toy)

	toy.collected.connect(_on_toy_collected)
	toy.danger_triggered.connect(_on_toy_danger_triggered)

func update_cleaned_label():
	cleaned_label.text = "Cleaned: " + str(cleaned_mess_count) + "/" + str(current_level["required_clean_count"])

func request_next_mess():
	if game_over or level_completed:
		return

	if is_baby_busy:
		return

	if current_level.is_empty():
		return

	if next_mess_index >= mess_sequence.size():
		return

	if get_active_mess_count() >= current_level["max_active_messes"]:
		return

	var mess_data = mess_sequence[next_mess_index]
	next_mess_index += 1

	var target_position = get_screen_position_from_percent(mess_data["position"])
	var object_name = mess_data["object"]

	is_baby_busy = true
	baby.perform_mess_at(target_position, object_name)

func spawn_specific_object_near_position(object_name, spawn_position):
	if get_active_mess_count() >= current_level["max_items"]:
		return

	var object_data = get_object_data_by_name(object_name)

	var toy = toy_scene.instantiate()
	toy.setup(object_data)

	var random_offset = Vector2(
		randf_range(-35, 35),
		randf_range(-20, 20)
	)

	toy.position = spawn_position + random_offset

	add_child(toy)

	toy.collected.connect(_on_toy_collected)
	toy.danger_triggered.connect(_on_toy_danger_triggered)

func get_object_data_by_name(object_name):
	for object_data in object_types:
		if object_data["name"] == object_name:
			return object_data

	return object_types[0]

func get_screen_position_from_percent(percent_position):
	var screen_size = get_viewport_rect().size

	return Vector2(
		screen_size.x * percent_position.x,
		screen_size.y * percent_position.y
	)

func get_active_mess_count():
	var count = 0

	for toy in get_tree().get_nodes_in_group("toys"):
		if not toy.is_collected:
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
