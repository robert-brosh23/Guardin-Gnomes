class_name Card
extends Area2D

enum states {DEFAULT, HOVERING, DRAGGING, PLACED, LOCKED, AWAY}

const SCENE := preload("res://ui/prgramming_track_ui/card/card.tscn")

@export var data: CardData

@export var draggable: Draggable
@export var card_image: TextureRect
@export var lock_image: Sprite2D

var state: states
var hand: Hand
var tween: Tween

static func create_card(card_data: CardData):
	var card : Card = SCENE.instantiate()
	card.data = card_data
	return card

func _ready():
	hand = get_tree().get_first_node_in_group("hand")
	draggable.drag_layer_parent = hand
	
	card_image.texture = data.texture
	
	state = states.DEFAULT
	draggable.drag_started.connect(_on_drag_started)
	draggable.drag_ended.connect(_on_drag_ended)
	
func lock_card():
	lock_image.visible = true
	state = states.LOCKED

func unlock_card():
	lock_image.visible = false
	state = states.PLACED
	
func activate():
	SignalBus.activate_card.emit(data)
	
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
	
func tween_to_pos(pos: Vector2, time: float = .2, trans: Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR, ease: Tween.EaseType = Tween.EaseType.EASE_IN_OUT):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "global_position", pos, time).set_trans(trans).set_ease(ease)
