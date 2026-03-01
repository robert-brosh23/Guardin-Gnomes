class_name Gnome
extends Node2D

signal try_move(Gnome, Direction)

enum Direction {UP_LEFT, UP_RIGHT, DOWN_RIGHT, DOWN_LEFT}
enum GnomeState {IDLE, JUMPING}

@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer

var jump_tween: Tween
var direction: Direction
var state: GnomeState

## FAR LEFT SIDE IS (0,0), TOP IS (11,0), FAR RIGHT SIDE IS (11,11), BOTTOM IS (0,11)
var grid_pos: Vector2i = Vector2i(6,5)

func _ready():
	direction = Direction.DOWN_RIGHT
	state = GnomeState.IDLE
	_update_idle_animation()
	
func _process(delta: float) -> void:
	_check_debug_commands()
	
func _check_debug_commands():
	if Input.is_action_just_pressed("forward"):
		try_move_forward()
	if Input.is_action_just_pressed("left"):
		turn_left()
	if Input.is_action_just_pressed("right"):
		turn_right()

func try_move_forward():
	var new_pos: Vector2i
	match direction:
		Direction.UP_LEFT:
			new_pos = grid_pos + Vector2i(0, -1)
		Direction.UP_RIGHT:
			new_pos = grid_pos + Vector2i(1, 0)
		Direction.DOWN_RIGHT:
			new_pos = grid_pos + Vector2i(0, 1)
		Direction.DOWN_LEFT:
			new_pos = grid_pos + Vector2i(-1, 0)
	try_move.emit(self, new_pos)

func move_to_space(new_pos: Vector2i):
	_do_jump_animation()
	grid_pos = new_pos
	_update_idle_animation()
	
func turn_right():
	if direction == Direction.DOWN_LEFT:
		direction = Direction.UP_LEFT
	else:
		direction += 1
	_update_idle_animation()
	
func turn_left():
	if direction == Direction.UP_LEFT:
		direction = Direction.DOWN_LEFT
	else:
		direction -= 1
	_update_idle_animation()

func spin():
	var roll := randi() % 4
	match roll:
		0: turn_left()
		1: turn_right()
		2: for i in 2: turn_right()
		3: for i in 2: turn_left()

func _do_jump_animation():
	var direction_vector := _get_animation_direction_vector()
	animation_tree.set("parameters/conditions/idle", false)
	animation_tree.set("parameters/Jump/blend_position", direction_vector)
	animation_tree.set("parameters/conditions/jump", true)
	
func _update_idle_animation():
	var direction_vector := _get_animation_direction_vector()
	# animation_tree.set("parameters/conditions/jump", false)
	animation_tree.set("parameters/Idle/blend_position", direction_vector)
	animation_tree.set("parameters/conditions/idle", true)
	
func _get_animation_direction_vector() -> Vector2:
	var direction_vector: Vector2
	match direction:
		Direction.UP_LEFT:
			direction_vector = Vector2(-1, 1)
		Direction.UP_RIGHT:
			direction_vector = Vector2(1, 1)
		Direction.DOWN_RIGHT:
			direction_vector = Vector2(1, -1)
		Direction.DOWN_LEFT:
			direction_vector = Vector2(-1, -1)
	return direction_vector
	
