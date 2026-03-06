class_name Hand
extends Node2D

const CENTER_X = 320
const DEFAULT_Y = 420
const DEFAULT_CARD_SEPARATION = 170
const DECK_POSITION := Vector2(-50, 200)
const DISCARD_POSITION := Vector2(950, 400)

@export var card_datas: Array[CardData]
@export var cards_in_deck_label: Label
@export var cards_in_discard_label: Label

var cards_in_deck: Array[Card]
var cards_in_hand: Array[Card]
var cards_in_discard: Array[Card]

var hovered_card: Array[Card]
var dragging_card: Card

var programming_track_ui: ProgrammingTrackUI


func _ready() -> void:
	programming_track_ui = get_tree().get_first_node_in_group("programming_track")
	_setup_deck_and_discard_and_hand()
	move_cards_from_discard_to_deck_and_shuffle()
	draw_cards()

func _process(delta: float) -> void:
	
	_update_hand()
	if GameManager.game_state == GameManager.GameState.DRAWING or GameManager.game_state == GameManager.GameState.DISCARDING:
		hovered_card.clear()
	
	if dragging_card:
		hovered_card.erase(dragging_card)
		return
		
	for card in cards_in_hand:
		if !hovered_card.is_empty() and hovered_card[0] == card:
			hovered_card[0].state = Card.states.HOVERING
		else:
			if card.state == Card.states.HOVERING:
				card.state = Card.states.DEFAULT

func draw_cards(num_cards: int = 9, lock_first: bool = true):
	if GameManager.check_if_has(UpgradeData.UpgradeType.DIVINE):
		num_cards += 2
	GameManager.game_state = GameManager.GameState.DRAWING
	if lock_first:
		if cards_in_deck.is_empty():
			move_cards_from_discard_to_deck_and_shuffle()
		if !cards_in_deck.is_empty():
			var card = cards_in_deck.get(0)
			var result := programming_track_ui.try_attach_and_lock_card(card)
			if result:
				cards_in_deck.erase(card)
				num_cards -= 1
				
	for i in range(num_cards):
		if cards_in_deck.is_empty():
			move_cards_from_discard_to_deck_and_shuffle()
		if !cards_in_deck.is_empty():
			await get_tree().create_timer(.1).timeout
			var card = cards_in_deck.get(0)
			cards_in_deck.remove_at(0)
			add_card_to_hand(card)
	GameManager.game_state = GameManager.GameState.MANIPULATING
	
func move_cards_from_discard_to_deck_and_shuffle():
	for i in range(cards_in_discard.size()):
		var card = cards_in_discard.get(0)
		card.global_position = DECK_POSITION
		cards_in_deck.append(card)
		cards_in_discard.erase(card)
	
	for i in range(cards_in_deck.size() - 1, 0, -1):
		var j = randi() % (i + 1)
		var temp = cards_in_deck[i]
		cards_in_deck[i] = cards_in_deck[j]
		cards_in_deck[j] = temp
	
func discard_hand():
	if dragging_card:
		dragging_card.draggable.stop_dragging_card()
	for i in range(cards_in_hand.size()):
		var card = cards_in_hand.get(0)
		card.state = card.states.AWAY
		card.tween_to_pos(DISCARD_POSITION)
		cards_in_discard.append(card)
		remove_card_from_hand(card)
		
func add_card_to_hand(card: Card):
	card.mouse_entered.connect(_hover_card.bind(card))
	card.mouse_exited.connect(_stop_hover_card.bind(card))
	cards_in_hand.append(card)
	card.call_deferred("reparent",self)
	card.state = Card.states.DEFAULT

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
				card.tween_to_pos(Vector2(x_pos, DEFAULT_Y))
				card.z_index = _z_index
				_z_index += 1
				
			card.states.HOVERING:
				if card.global_position.y < DEFAULT_Y - 40 or card.global_position.x > CENTER_X + 250 :
					card.tween_to_pos(Vector2(x_pos, DEFAULT_Y))
					card.z_index = _z_index
					_z_index += 1
				else:
					card.tween_to_pos(Vector2(card.global_position.x, DEFAULT_Y - 40))
					card.z_index = 11
				
			card.states.DRAGGING:
				pass
			
		x_pos += card_separation

func _determine_card_separation() -> int:
	return DEFAULT_CARD_SEPARATION / 4 + DEFAULT_CARD_SEPARATION * 3 / 4 / (cards_in_hand.size() + 1)
	
func _stop_hover_card(card: Card):
	if !cards_in_hand.has(card):
		return
	hovered_card.erase(card)
	
func _hover_card(card: Card):
	if !card.state == Card.states.DEFAULT:
		return
	if !cards_in_hand.has(card):
		return
	hovered_card.append(card)

func _on_turn_end():
	discard_hand()
	await get_tree().create_timer(.5).timeout
	draw_cards()
	

func _setup_deck_and_discard_and_hand():
	for card_data in card_datas:
		var card = Card.create_card(card_data)
		cards_in_deck.append(card)
		card.position = DECK_POSITION
		add_child(card)
	for card in cards_in_deck:
		card.state = Card.states.AWAY
		card.mouse_entered.connect(func(): _hover_card(card))
		card.mouse_exited.connect(func(): _stop_hover_card(card))
	for card in cards_in_discard:
		card.state = Card.states.AWAY
		card.mouse_entered.connect(func(): _hover_card(card))
		card.mouse_exited.connect(func(): _stop_hover_card(card))
	for card in cards_in_hand:
		card.state = Card.states.DEFAULT
		card.mouse_entered.connect(func(): _hover_card(card))
		card.mouse_exited.connect(func(): _stop_hover_card(card))
	
