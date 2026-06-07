extends Node2D

signal mess_created(position, object_name, object_id)

enum BabyState {
	IDLE,
	WALK,
	MESS,
	DANCE
}


const HEAD_IDLE_BOUNCE = 1.2
const HEAD_WALK_BOUNCE = 1.5
const LEG_WALK_ANGLE = 13.0
const ARM_WALK_ANGLE = 7.0
const MESS_ARM_ANGLE = -14.0
const MESS_HEAD_FORWARD = 10.0
const MESS_HEAD_DOWN = 7.0
const BABY_SCALE = 0.65

var current_state = BabyState.IDLE
var is_active = false

var move_target = Vector2.ZERO
var move_speed = 170.0
var walk_time = 0.0

var pending_object_name = ""
var pending_mess_position = Vector2.ZERO
var pending_object_id = ""

@onready var body_pivot = $BodyPivot
@onready var head_pivot = $HeadPivot
@onready var back_arm_pivot = $BackArmPivot
@onready var front_arm_pivot = $FrontArmPivot
@onready var back_leg_pivot = $BackLegPivot
@onready var front_leg_pivot = $FrontLegPivot
@onready var action_timer = $ActionTimer

func _ready():
	randomize()
	visible = false
	action_timer.one_shot = true
	action_timer.stop()

func start_baby():
	is_active = true
	visible = true
	scale = Vector2(BABY_SCALE, BABY_SCALE)

	position = Vector2(700, 600)

	reset_pose()
	go_idle()

func stop_baby():
	is_active = false
	visible = false
	action_timer.stop()
	reset_pose()

func _process(delta):
	if not is_active:
		return
		
	z_index = int(global_position.y)

	match current_state:
		BabyState.WALK:
			process_walk(delta)
 
		BabyState.IDLE:
			process_idle(delta)

		BabyState.DANCE:
			process_dance(delta)

func perform_mess_at(target_position, object_name, mess_position, object_id):
	if not is_active:
		return

	pending_object_name = object_name
	pending_mess_position = mess_position
	pending_object_id = object_id

	move_target = target_position
	go_walk()

func process_idle(delta):
	walk_time += delta * 1.4
	head_pivot.position.y = -52 + sin(walk_time) * HEAD_IDLE_BOUNCE

func go_idle():
	current_state = BabyState.IDLE
	reset_pose()

func go_walk():
	current_state = BabyState.WALK

	if move_target.x < position.x:
		scale.x = -BABY_SCALE
	else:
		scale.x = BABY_SCALE

	scale.y = BABY_SCALE

func process_walk(delta):
	walk_time += delta * 6.5

	position = position.move_toward(move_target, move_speed * delta)

	var leg_rotation = sin(walk_time) * LEG_WALK_ANGLE
	var arm_rotation = sin(walk_time) * ARM_WALK_ANGLE

	front_leg_pivot.rotation_degrees = leg_rotation
	back_leg_pivot.rotation_degrees = -leg_rotation

	front_arm_pivot.rotation_degrees = -arm_rotation
	back_arm_pivot.rotation_degrees = arm_rotation

	head_pivot.position.y = -52 + abs(sin(walk_time * 2.0)) * HEAD_WALK_BOUNCE

	if position.distance_to(move_target) < 8:
		reset_pose()
		make_mess()

func make_mess():
	current_state = BabyState.MESS

	var tween = create_tween()

	tween.parallel().tween_property(front_arm_pivot, "rotation_degrees", MESS_ARM_ANGLE, 0.14)
	tween.parallel().tween_property(head_pivot, "position:x", MESS_HEAD_FORWARD, 0.14)
	tween.parallel().tween_property(head_pivot, "position:y", -52 + MESS_HEAD_DOWN, 0.14)

	tween.tween_property(front_arm_pivot, "rotation_degrees", 0, 0.14)
	tween.parallel().tween_property(head_pivot, "position:x", 0, 0.14)
	tween.parallel().tween_property(head_pivot, "position:y", -52, 0.14)

	await tween.finished

	if not is_active:
		return

	mess_created.emit(pending_mess_position, pending_object_name, pending_object_id)

	go_idle()

func reset_pose():
	front_leg_pivot.rotation_degrees = 0
	back_leg_pivot.rotation_degrees = 0

	front_arm_pivot.rotation_degrees = 0
	back_arm_pivot.rotation_degrees = 0

	head_pivot.position.x = 0
	head_pivot.position.y = -52

func _on_action_timer_timeout():
	pass

func start_dancing():
	reset_pose()

	current_state = BabyState.DANCE

func process_dance(delta):

	walk_time += delta * 3.5

	var leg_rotation = sin(walk_time) * 8.0
	var arm_rotation = cos(walk_time) * 12.0

	front_leg_pivot.rotation_degrees = leg_rotation
	back_leg_pivot.rotation_degrees = -leg_rotation

	front_arm_pivot.rotation_degrees = arm_rotation
	back_arm_pivot.rotation_degrees = -arm_rotation

	head_pivot.position.x = sin(walk_time * 2.0) * 10.0
	head_pivot.position.y = -52
	
	body_pivot.position.x = sin(walk_time) * 2.0

	head_pivot.rotation_degrees = 0
