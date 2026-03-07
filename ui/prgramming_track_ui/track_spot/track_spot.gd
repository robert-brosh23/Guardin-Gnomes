class_name TrackSpot
extends Area2D

@export var number: int
@export var dropzone: DropZone
@export var card_highlight: TextureRect
@onready var number_label := %Label

var place_card_sound := preload("res://audio/Cozy UI A2.wav")

func _ready():
	number_label.text = str(number)
	dropzone.drop_applied.connect(func(zone, area, plan): AudioPlayer.play_sound(place_card_sound))

func attach_card(card: Card) -> bool:
	var dropped = dropzone.try_dropping(card)
	if dropped != null:
		card.tween_to_pos(global_position, 1.0, Tween.TransitionType.TRANS_CUBIC, Tween.EaseType.EASE_OUT)
		return true
		
	return false

func activate(track_index: int, highlight_card: bool = true):
	card_highlight.visible = highlight_card
	var card : Card = get_child_of_type(self, Card)
	if card != null:
		card.activate(track_index)
	
func de_activate():
	card_highlight.visible = false

func get_child_of_type(node: Node, type: Variant) -> Node:
	for child in node.get_children():
		if is_instance_of(child, type):
			return child
	return null
