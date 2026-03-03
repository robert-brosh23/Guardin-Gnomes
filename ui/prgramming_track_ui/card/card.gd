class_name Card
extends Area2D

enum states {DEFAULT, HOVERING, DRAGGING, PLACED}

@export var data: CardData

@export var draggable: Draggable
@export var card_image: TextureRect

var state: states
var hand: Hand
var tween: Tween

func _ready():
	hand = get_tree().get_first_node_in_group("hand")
	draggable.drag_layer_parent = hand
	
	card_image.texture = data.texture
	
	state = states.DEFAULT
	draggable.drag_started.connect(_on_drag_started)
	draggable.drag_ended.connect(_on_drag_ended)
	
func activate():
	SignalBus.activate_card.emit(data.card_action)
	
func _on_drag_started(_area2d: Area2D):
	state = states.DRAGGING
	tween.kill()
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
	
func add_self_to_hand():
	hand.add_card_to_hand(self)
	
func tween_to_pos(pos: Vector2):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "global_position", pos, .2)
