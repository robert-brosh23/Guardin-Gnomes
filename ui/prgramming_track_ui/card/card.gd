class_name Card
extends Area2D

enum states {DEFAULT, HOVERING, DRAGGING, PLACED}

@export var draggable: Draggable

var state: states
var hand: Hand

func _ready():
	state = states.DEFAULT
	draggable.drag_started.connect(func(_area2d: Area2D): state = states.DRAGGING)
	draggable.drag_ended.connect(_on_drag_ended)
	
	hand = get_tree().get_first_node_in_group("hand")
	
func _on_drag_ended(_area2d: Area2D, _snapping_spot: SnappingSpot):
	if _snapping_spot != null:
		state = states.PLACED
		hand.cards_in_hand.erase(self)
	else:
		state = states.DEFAULT
		if !hand.cards_in_hand.has(self):
			hand.cards_in_hand.append(self)
		call_deferred("reparent", hand)
		
