class_name Gnome
extends Node2D

signal try_move(Gnome, Direction)

enum Direction {UP_LEFT, UP_RIGHT, DOWN_RIGHT, DOWN_LEFT}

var direction: Direction

## FAR LEFT SIDE IS (0,0), TOP IS (11,0), FAR RIGHT SIDE IS (11,11), BOTTOM IS (0,11)
var grid_pos: Vector2i = Vector2i(6,5)

func _ready():
	direction = Direction.DOWN_RIGHT
	
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
	grid_pos = new_pos
	
func turn_right():
	if direction == Direction.DOWN_LEFT:
		direction = Direction.UP_LEFT
	else:
		direction += 1
	
func turn_left():
	if direction == Direction.UP_LEFT:
		direction = Direction.DOWN_LEFT
	else:
		direction -= 1
