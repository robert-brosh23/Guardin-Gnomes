class_name Gnome
extends Node2D

signal try_move(Gnome, Direction)

enum Direction {UP_LEFT, UP_RIGHT, DOWN_RIGHT, DOWN_LEFT}
enum GnomeColor {RED, GREEN, BLUE}

@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer
@export var state_machine: StateMachine
@export var jump_state: JumpState
@export var sprite: Sprite2D

var jump_tween: Tween
var direction: Direction
var stuck_count: int
var color: GnomeColor
var upgrades: Array[String]

## FAR LEFT SIDE IS (0,0), TOP IS (11,0), FAR RIGHT SIDE IS (11,11), BOTTOM IS (0,11)
var grid_pos: Vector2i = Vector2i(6,5)
var new_pos: Vector2i
var try_move_distance: int

func _ready():
	_set_color()
	_update_blend_positions()
	SignalBus.activate_card.connect(_try_action)

func try_move_forward(amount: int = 1):
	match direction:
		Direction.UP_LEFT:
			new_pos = grid_pos + Vector2i(0, amount * -1)
		Direction.UP_RIGHT:
			new_pos = grid_pos + Vector2i(amount, 0)
		Direction.DOWN_RIGHT:
			new_pos = grid_pos + Vector2i(0, amount)
		Direction.DOWN_LEFT:
			new_pos = grid_pos + Vector2i(amount * -1, 0)
	try_move.emit(self, new_pos)

func move_to_space(_new_pos: Vector2i, new_physical_pos: Vector2):
	grid_pos = _new_pos
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

func teleport(new_pos: Vector2i, new_physical_pos: Vector2):
	grid_pos = new_pos
	jump_state.new_physical_pos = new_physical_pos
	state_machine.active_state.Transitioned.emit(state_machine.active_state, "JumpState")
	var teleport_pos = Vector2i(2,4)

func is_idle() -> bool:
	if is_instance_of(state_machine.active_state, IdleState):
		return true
	return false

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
	
func _try_action(data: CardData, track_index: int):
	if !data.color.has(color):
		return
		
	try_move_distance = 1
	if color == GnomeColor.GREEN and GameManager.check_if_has(UpgradeData.UpgradeType.AGILE):
		try_move_distance *= 2
	
	match data.card_action:
		CardData.CardAction.FORWARD_ONE:
			try_move_forward(try_move_distance)
		CardData.CardAction.U_TURN:
			turn_right()
			turn_right()
		CardData.CardAction.FORWARD_TWO:
			try_move_distance *= 2
			try_move_forward(try_move_distance)
		CardData.CardAction.RIGHT_TURN:
			turn_right()
		CardData.CardAction.LEFT_TURN:
			turn_left()
		CardData.CardAction.FORWARD_THREE:
			try_move_distance *= 3
			try_move_forward(try_move_distance)

func _set_color():
	if color == GnomeColor.GREEN: sprite.texture = load("uid://cnil47ngwlo1q")
	if color == GnomeColor.RED: sprite.texture = load("uid://c1eff46jfb1x4")
	if color == GnomeColor.BLUE: sprite.texture = load("uid://2gdyvmldocwe")
