extends Control

const DEFAULT_CHAOS_SPEED = 5.0
const DEFAULT_SPAWN_SPEED = 1.2
const TOY_SIZE = Vector2(96, 96)

var toy_scene = preload("res://toy.tscn")

var score = 0
var chaos = 0.0
var game_over = false
var chaos_speed = DEFAULT_CHAOS_SPEED
var spawn_speed = DEFAULT_SPAWN_SPEED

var object_types = [
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

@onready var score_label = $ScoreLabel
@onready var chaos_bar = $ChaosBar
@onready var game_over_label = $GameOverLabel
@onready var spawn_timer = $SpawnTimer
@onready var restart_button = $RestartButton
@onready var menu_panel = $MenuPanel
@onready var play_button = $MenuPanel/PlayButton
@onready var title_label = $MenuPanel/TitleLabel

func _ready():
	randomize()
	setup_restart_button_style()
	center_game_over_ui()
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

	for toy in get_tree().get_nodes_in_group("toys"):
		toy.queue_free()

	update_score_label()
	update_chaos_bar()

	spawn_timer.wait_time = spawn_speed
	spawn_timer.start()

func _process(delta):
	if game_over:
		return

	chaos += chaos_speed * delta
	update_chaos_bar()

	if chaos >= 100:
		end_game()

func spawn_toy():
	if game_over:
		return

	var object_data = get_random_object_data()

	var toy = toy_scene.instantiate()
	toy.setup(object_data)
	toy.position = get_random_toy_position()

	add_child(toy)

	toy.collected.connect(_on_toy_collected)
	toy.danger_triggered.connect(_on_toy_danger_triggered)

func _on_toy_collected(toy, score_value, chaos_reduce):
	if game_over:
		return

	score += score_value
	chaos -= chaos_reduce

	if chaos < 0:
		chaos = 0

	update_score_label()
	update_chaos_bar()
	update_difficulty()

func update_score_label():
	score_label.text = "Score: " + str(score)

func update_chaos_bar():
	chaos_bar.value = chaos

func end_game():
	game_over = true
	spawn_timer.stop()

	for toy in get_tree().get_nodes_in_group("toys"):
		toy.disable_click()

	game_over_label.visible = true
	restart_button.visible = true

	center_game_over_ui()

	game_over_label.move_to_front()
	restart_button.move_to_front()

func _on_spawn_timer_timeout():
	spawn_toy()

func get_random_toy_position():
	var screen_size = get_viewport_rect().size

	for i in range(20):
		var x = randf_range(50, screen_size.x - TOY_SIZE.x - 50)
		var y = randf_range(130, screen_size.y - TOY_SIZE.y - 50)
		var position = Vector2(x, y)

		if not is_position_overlapping(position):
			return position

	return Vector2(
		randf_range(50, screen_size.x - TOY_SIZE.x - 50),
		randf_range(130, screen_size.y - TOY_SIZE.y - 50)
	)

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
	chaos_speed = DEFAULT_CHAOS_SPEED + (score * 0.12)
	spawn_speed = max(0.35, DEFAULT_SPAWN_SPEED - (score * 0.02))
	spawn_timer.wait_time = spawn_speed

func setup_restart_button_style():
	restart_button.text = "Restart"

	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color("#FF4D4D")
	normal_style.corner_radius_top_left = 12
	normal_style.corner_radius_top_right = 12
	normal_style.corner_radius_bottom_left = 12
	normal_style.corner_radius_bottom_right = 12

	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color("#FF6B6B")
	hover_style.corner_radius_top_left = 12
	hover_style.corner_radius_top_right = 12
	hover_style.corner_radius_bottom_left = 12
	hover_style.corner_radius_bottom_right = 12
	
	var pressed_style = StyleBoxFlat.new()
	pressed_style.bg_color = Color("#D93636")
	pressed_style.corner_radius_top_left = 12
	pressed_style.corner_radius_top_right = 12
	pressed_style.corner_radius_bottom_left = 12
	pressed_style.corner_radius_bottom_right = 12

	restart_button.add_theme_stylebox_override("normal", normal_style)
	restart_button.add_theme_stylebox_override("hover", hover_style)
	restart_button.add_theme_stylebox_override("pressed", pressed_style)
	restart_button.add_theme_color_override("font_color", Color("#FFFFFF"))
	restart_button.add_theme_font_size_override("font_size", 28)

func _on_restart_button_pressed() -> void:
	start_new_game()
	
func center_game_over_ui():
	var screen_size = get_viewport_rect().size

	game_over_label.size = Vector2(400, 70)
	game_over_label.position = Vector2(
		(screen_size.x - game_over_label.size.x) / 2,
		(screen_size.y / 2) - 90
	)
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	restart_button.size = Vector2(180, 60)
	restart_button.position = Vector2(
		(screen_size.x - restart_button.size.x) / 2,
		(screen_size.y / 2) + 10
	)


func show_main_menu():
	game_over = true
	menu_panel.visible = true
	game_over_label.visible = false
	restart_button.visible = false
	spawn_timer.stop()

	for toy in get_tree().get_nodes_in_group("toys"):
		toy.queue_free()

	setup_menu_style()
	center_menu_ui()

func center_menu_ui():
	var screen_size = get_viewport_rect().size

	title_label.size = Vector2(500, 80)
	title_label.position = Vector2(
		(screen_size.x - title_label.size.x) / 2,
		(screen_size.y / 2) - 130
	)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	play_button.size = Vector2(180, 60)
	play_button.position = Vector2(
		(screen_size.x - play_button.size.x) / 2,
		(screen_size.y / 2)
	)

func setup_menu_style():
	title_label.add_theme_color_override("font_color", Color("#FFFFFF"))
	title_label.add_theme_font_size_override("font_size", 56)

	var play_style = StyleBoxFlat.new()
	play_style.bg_color = Color("#FFD23F")
	play_style.corner_radius_top_left = 12
	play_style.corner_radius_top_right = 12
	play_style.corner_radius_bottom_left = 12
	play_style.corner_radius_bottom_right = 12

	play_button.add_theme_stylebox_override("normal", play_style)
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
		if score >= object_data["unlock_score"]:
			available_objects.append(object_data)

	return available_objects.pick_random()
