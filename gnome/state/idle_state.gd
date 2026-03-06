class_name IdleState
extends GnomeBaseState

var main: Main

func _ready() -> void:
	main = get_tree().get_first_node_in_group("main")

func enter() -> void:
	super()
	gnome.animation_tree.set("parameters/conditions/idle", true)
	
func exit() -> void:
	super()
	gnome.animation_tree.set("parameters/conditions/idle", false)

func update(_delta: float):
	super(_delta)
	_check_debug_commands()

func _check_debug_commands():
	if !main.debug_enabled:
		return
	if Input.is_action_just_pressed("forward"):
		gnome.try_move_distance = 3
		gnome.try_move_forward(3)
	if Input.is_action_just_pressed("left"):
		gnome.turn_left()
	if Input.is_action_just_pressed("right"):
		gnome.turn_right()
