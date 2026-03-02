class_name Card
extends Area2D

enum states {DEFAULT, HOVERING, DRAGGING, PLACED}

@export var draggable: Draggable

var state: states
var hand: Hand

func _ready():
	hand = get_tree().get_first_node_in_group("hand")
	draggable.drag_layer_parent = hand
	
	state = states.DEFAULT
	draggable.drag_started.connect(_on_drag_started)
	draggable.drag_ended.connect(_on_drag_ended)
	
func _on_drag_started(_area2d: Area2D):
	state = states.DRAGGING
	hand.remove_card_from_hand(self)
	z_index = 12
	hand.dragging_card = self

func _on_drag_ended(_area2d: Area2D, _snapping_spot: SnappingSpot):
	hand.dragging_card = null
	if _snapping_spot != null:
		state = states.PLACED
	else:
		state = states.DEFAULT
		if !hand.cards_in_hand.has(self):
			hand.add_card_to_hand(self)
	
