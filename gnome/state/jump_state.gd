class_name JumpState
extends GnomeBaseState

var new_physical_pos: Vector2

func enter() -> void:
	super()
	gnome.animation_tree.set("parameters/conditions/jump", true)
	
	do_jump()
	
func exit() -> void:
	super()
	gnome.animation_tree.set("parameters/conditions/jump", false)
	
func do_jump():
	var horizontal_tween = create_tween()
	var vertical_tween = create_tween()
	
	horizontal_tween.tween_property(gnome, "global_position", new_physical_pos, 0.8)
	horizontal_tween.finished.connect(_on_tween_finished)
	
	var sprite_starting_pos = gnome.sprite.position.y
	
	vertical_tween.set_trans(Tween.TRANS_SINE)
	vertical_tween.set_ease(Tween.EASE_OUT)
	vertical_tween.tween_property(gnome.sprite, "position:y", sprite_starting_pos - 50, 0.4)
	vertical_tween.set_ease(Tween.EASE_IN)
	vertical_tween.tween_property(gnome.sprite, "position:y", sprite_starting_pos, 0.4)

func _on_tween_finished():
	Transitioned.emit(self, "IdleState")
