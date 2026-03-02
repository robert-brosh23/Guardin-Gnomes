class_name ActionRelocate extends DropAction

var occupant: Area2D
var target_spot: SnappingSpot

func _init(p_occupant: Area2D, p_spot: SnappingSpot):
	occupant = p_occupant
	target_spot = p_spot

func execute(zone: DropZone) -> void:
	if target_spot == null:
		var draggable = occupant.get_meta("draggable")
		if draggable:
			var card: Card = draggable.get_parent()
			card.add_self_to_hand()
		return
			
	DropUtils.clear_occupant_reference(zone, occupant)
	target_spot.occupant = occupant
	zone.occupant_changed.emit(zone, target_spot, null, occupant)

	var draggable = occupant.get_meta("draggable")
	if draggable:
		draggable.move_to(target_spot.point.global_position)
