class_name HazardDetector
extends Area2D

signal hazard_entered(hazard_type)

const bitmask: int = 255	# will need updating if adding more HazardTypes

enum HazardType {
	THORN_BUSH = 1,
	ROCK = 2,
	HAZARD3 = 4,
	HAZARD4 = 8,
	HAZARD5 = 16
}

var current_tilemap: TileMap
var current_hazard_area: HazardArea
var previous_hazard: int = -1
var current_hazard: int = -1

func _exit_tree() -> void:
	current_tilemap = null
	current_hazard = -1

func _process_tilemap_collision(body: Node2D, body_rid: RID) -> void:
	current_tilemap = body

	if current_hazard_area is HazardArea:
		return

	var collided_tile_coords = current_tilemap.get_coords_for_body_rid(body_rid)

	for i in current_tilemap.get_layers_count():
		var tile_data = current_tilemap.get_cell_tile_data(i, collided_tile_coords)
		if !tile_data is TileData:
			continue
		var hazard_mask = tile_data.get_custom_data_by_layer_id(0) # hazard layer
		_update_hazard(hazard_mask)
		break

func _process_hazard_area_collision(hazard_area: HazardArea) -> void:
	current_hazard_area = hazard_area
	_update_hazard(hazard_area.hazard_type)


func _update_hazard(hazard_mask: int) -> void:
	if hazard_mask != current_hazard:
		previous_hazard = current_hazard
		current_hazard = hazard_mask
		emit_signal("hazard_entered", current_hazard)
		
func current_hazard_matches(hazard: int) -> bool:
	return hazard & current_hazard != 0

func _on_body_shape_entered(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body is TileMap:
		_process_hazard_area_collision(area)

func _on_area_entered(area: Area2D) -> void:
	if area is HazardArea:_process_hazard_area_collision(area)

func _on_area_exited(area: Area2D) -> void:
	if current_hazard_area == area:
		current_hazard_area = null
