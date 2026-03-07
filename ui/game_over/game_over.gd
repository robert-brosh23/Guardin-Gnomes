extends Control

@onready var round_label := %RoundLabel
@onready var gold_label := %GoldLabel
@onready var lands_label := %LandsLabel

func _ready():
	round_label.text = "Made it to: Round " + str(GameManager.round_number_for_end)
	gold_label.text = "Gold Earned: " + str(GameManager.total_collected)
	lands_label.text = "Lands Purified: " + str(GameManager.total_purified)
