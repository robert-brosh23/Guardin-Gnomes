class_name TrackSpot
extends Area2D

@export var dropzone: DropZone
@export var card_highlight: TextureRect

func attach_card(card: Card) -> bool:
	var dropped = dropzone.try_dropping(card)
	print("tried attaching")
	if dropped != null:
		card.tween_to_pos(global_position, 1.0, Tween.TransitionType.TRANS_CUBIC, Tween.EaseType.EASE_OUT)
		return true
	return false

func activate(highlight_card: bool = true):
	card_highlight.visible = highlight_card
	var card : Card = get_child_of_type(self, Card)
	if card != null:
		card.activate()
	
func de_activate():
	card_highlight.visible = false

func get_child_of_type(node: Node, type: Variant) -> Node:
	for child in node.get_children():
		if is_instance_of(child, type):
			return child
	return null
