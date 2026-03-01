class_name Hand
extends Node2D

const CENTER_X = 320
const DEFAULT_Y = 420
const DEFAULT_CARD_SEPARATION = 150

@export var cards_in_hand: Array[Card]
var hovered_card: Card

func _process(delta: float) -> void:
	_update_hand()

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
				tween_to_pos(card, Vector2(card.global_position.x, DEFAULT_Y + 40))
				card.z_index = 12
				
			card.states.DRAGGING:
				pass
			
		x_pos += card_separation

func _determine_card_separation() -> int:
	return DEFAULT_CARD_SEPARATION / 4 + DEFAULT_CARD_SEPARATION * 3 / 4 / (cards_in_hand.size() + 1)

func tween_to_pos(node: Node, pos: Vector2):
	var tween := create_tween()
	tween.tween_property(node, "global_position", pos, .2)
	
	
