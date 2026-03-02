class_name Hand
extends Node2D

const CENTER_X = 320
const DEFAULT_Y = 420
const DEFAULT_CARD_SEPARATION = 150

@export var cards_in_hand: Array[Card]
var hovered_card: Array[Card]
var dragging_card: Card

func _ready() -> void:
	for card in cards_in_hand:
		card.mouse_entered.connect(func(): _hover_card(card))
		card.mouse_exited.connect(func(): _stop_hover_card(card))

func _process(delta: float) -> void:
	_update_hand()
	
	if dragging_card:
		hovered_card.erase(dragging_card)
		return
		
	for card in cards_in_hand:
		if !hovered_card.is_empty() and hovered_card[0] == card:
			hovered_card[0].state = Card.states.HOVERING
		else:
			if card.state == Card.states.HOVERING:
				card.state = Card.states.DEFAULT
				
func add_card_to_hand(card: Card):
	card.mouse_entered.connect(_hover_card.bind(card))
	card.mouse_exited.connect(_stop_hover_card.bind(card))
	cards_in_hand.append(card)
	card.call_deferred("reparent",self)

func remove_card_from_hand(card: Card):
	card.mouse_entered.disconnect(_hover_card.bind(card))
	card.mouse_exited.disconnect(_stop_hover_card.bind(card))
	cards_in_hand.erase(card)
	

func _update_hand():
	var card_separation: int = _determine_card_separation()
	var hand_length: int = card_separation * (cards_in_hand.size() - 1)
	var x_pos: int = CENTER_X - hand_length / 2
	var _z_index: int = 1
	
	for card in cards_in_hand:
		match card.state:
			card.states.DEFAULT:
				tween_to_pos(card, Vector2(x_pos, DEFAULT_Y))
				card.z_index = _z_index
				_z_index += 1
				
			card.states.HOVERING:
				tween_to_pos(card, Vector2(card.global_position.x, DEFAULT_Y - 40))
				card.z_index = 11
				
			card.states.DRAGGING:
				pass
			
		x_pos += card_separation

func _determine_card_separation() -> int:
	return DEFAULT_CARD_SEPARATION / 4 + DEFAULT_CARD_SEPARATION * 3 / 4 / (cards_in_hand.size() + 1)

func tween_to_pos(node: Node, pos: Vector2):
	var tween := create_tween()
	tween.tween_property(node, "global_position", pos, .2)
	
func _stop_hover_card(card: Card):
	if !cards_in_hand.has(card):
		return
	hovered_card.erase(card)
	
func _hover_card(card: Card):
	if !cards_in_hand.has(card):
		return
	hovered_card.append(card)
	
	
