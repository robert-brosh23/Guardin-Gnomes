class_name Gnome
extends Node2D

signal try_move(Gnome, Direction)

enum Direction {UP_LEFT, UP_RIGHT, DOWN_RIGHT, DOWN_LEFT}

@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer
@export var state_machine: StateMachine
@export var jump_state: JumpState
@export var sprite: Sprite2D

var jump_tween: Tween
var direction: Direction

## FAR LEFT SIDE IS (0,0), TOP IS (11,0), FAR RIGHT SIDE IS (11,11), BOTTOM IS (0,11)
var grid_pos: Vector2i = Vector2i(6,5)

func _ready():
	direction = Direction.DOWN_RIGHT
	_update_blend_positions()

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

func move_to_space(new_pos: Vector2i, new_physical_pos: Vector2):
	grid_pos = new_pos
	jump_state.new_physical_pos = new_physical_pos
	state_machine.active_state.Transitioned.emit(state_machine.active_state, "JumpState")
	
func turn_right():
	if direction == Direction.DOWN_LEFT:
		direction = Direction.UP_LEFT
	else:
		direction += 1
	_update_blend_positions()
	
func turn_left():
	if direction == Direction.UP_LEFT:
		direction = Direction.DOWN_LEFT
	else:
		direction -= 1
	_update_blend_positions()

func spin():
	var roll := randi() % 4
	match roll:
		0: turn_left()
		1: turn_right()
		2: for i in 2: turn_right()
		3: for i in 2: turn_left()
		
func _update_blend_positions():
	var blend_vector := _get_animation_direction_vector()
	animation_tree.set("parameters/Idle/blend_position", blend_vector)
	animation_tree.set("parameters/Jump/blend_position", blend_vector)
	
		
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
	
