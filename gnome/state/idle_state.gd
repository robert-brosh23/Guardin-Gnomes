class_name IdleState
extends GnomeBaseState

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
	if Input.is_action_just_pressed("forward"):
		gnome.try_move_forward()
	if Input.is_action_just_pressed("left"):
		gnome.turn_left()
	if Input.is_action_just_pressed("right"):
		gnome.turn_right()
