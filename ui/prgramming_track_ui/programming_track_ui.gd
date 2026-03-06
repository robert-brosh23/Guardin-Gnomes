class_name ProgrammingTrackUI
extends Control

@onready var track_spots: Array[TrackSpot] = [$TextureRect/TrackSpot, $TextureRect/TrackSpot2, $TextureRect/TrackSpot3, $TextureRect/TrackSpot4, $TextureRect/TrackSpot5]

@export var enchant_button: Button
var hand: Hand
var main: Main
var upgrade_menu: UpgradeMenu

var coins: int = 0
var active_index: int

func _ready():
	enchant_button.pressed.connect(_try_start_turn)
	hand = get_tree().get_first_node_in_group("hand")
	main = get_tree().get_first_node_in_group("main")
	upgrade_menu = get_tree().get_first_node_in_group("upgrade_menu")
	SignalBus.activate_card.connect(_on_card_activate)
	
func try_attach_and_lock_card(card: Card) -> bool:
	var selection := randi_range(0, track_spots.size() - 1)
	var result = track_spots.get(selection).attach_card(card)
	if result:
		card.lock_card()
	return result

func _try_start_turn():
	if GameManager.game_state == GameManager.GameState.MANIPULATING:
		GameManager.game_state = GameManager.GameState.ENCHANTING
		start_turn()
		
func move_cards_to_hand():
	for track_spot in track_spots:
		var card : Card = track_spot.get_child_of_type(track_spot, Card)
		if !card:
			continue
		track_spot.dropzone._detach(card)
		card.unlock_card()
		hand.add_card_to_hand(card)

func start_turn():
	active_index = 0
	for track_spot in track_spots:
		track_spot.activate(active_index)
		await get_tree().create_timer(1.0).timeout
		while !main.all_gnomes_idle():
			await get_tree().create_timer(.05).timeout
		
		track_spot.de_activate()
		active_index+=1	
	
	while coins > 0:
		coins -= 1
		if GameManager.upgrades.size() < 10:
			upgrade_menu.open_upgrade_menu()
			await upgrade_menu.chosen
	
	move_cards_to_hand()
	GameManager.game_state = GameManager.GameState.DISCARDING
	SignalBus.turn_end.emit()
	
func _on_card_activate(card_data: CardData, track_index: int):
	if card_data.card_action == CardData.CardAction.AGAIN and track_index > 0:
		var last_index := track_index - 1
		track_spots.get(last_index).activate(last_index, false) # activate silently

func get_child_of_type(node: Node, type: Variant) -> Node:
	for child in node.get_children():
		if is_instance_of(child, type):
			return child
	return null
