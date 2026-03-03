class_name TrackSpot
extends Area2D

@export var dropzone: DropZone
@export var card_highlight: TextureRect

func activate():
	card_highlight.visible = true
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
