class_name ProgrammingTrackUI
extends Control

@onready var track_spots: Array[TrackSpot] = [$TextureRect/TrackSpot, $TextureRect/TrackSpot2, $TextureRect/TrackSpot3, $TextureRect/TrackSpot4, $TextureRect/TrackSpot5]

func _ready():
	start_turn()

func start_turn():
	for track_spot in track_spots:
		track_spot.activate()
		await get_tree().create_timer(1.0).timeout
		track_spot.de_activate()
	
	# Loop for now
	await get_tree().create_timer(.5).timeout
	start_turn()
			

func get_child_of_type(node: Node, type: Variant) -> Node:
	for child in node.get_children():
		if is_instance_of(child, type):
			return child
	return null
