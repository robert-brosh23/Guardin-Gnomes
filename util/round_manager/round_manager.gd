class_name RoundManager
extends Node

@onready var tile_map_layers: Node2D = $"TileMapLayers"
@onready var base_layer: TileMapLayer = $"TileMapLayers/BaseLayer"
@onready var hazard_layer: TileMapLayer = $"TileMapLayers/HazardLayer"

const PIXIE_SOURCE_ID := 2

var pixie_circle_1_tiles: Array[Vector2i]
var pixie_circle_2_tiles: Array[Vector2i]
var pixie_circle_3_tiles: Array[Vector2i]
var pixie_hazard_tiles: Array[Vector2i]


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("next_round"):
		_on_next_round()
		print("next round")


func _on_next_round():
	pixie_grow()
	pixie_spread()
	pixie_rand_spawn()



func pixie_rand_spawn():
	var target_pos = tile_map_layers.get_random_empty_cell()
	if target_pos != Vector2i(-1000,-1000):
		base_layer.set_cell(target_pos + Vector2i(-1,1), PIXIE_SOURCE_ID, Vector2i(0,0))


func pixie_grow():
	_check_pixie_tiles()
	for tile_pos in pixie_circle_1_tiles:
		base_layer.set_cell(tile_pos, PIXIE_SOURCE_ID, Vector2i(0,4))
	for tile_pos in pixie_circle_2_tiles:
		base_layer.set_cell(tile_pos, PIXIE_SOURCE_ID, Vector2i(0,8))
		hazard_layer.set_cell(tile_pos + Vector2i(1,-1), 10, Vector2i(0,0))


func pixie_spread():
	for tile_pos in pixie_hazard_tiles:
		var target_pos = _get_adjacent_empty_cell(tile_pos)
		if target_pos != Vector2i(-1000,-1000):
			base_layer.set_cell(target_pos, PIXIE_SOURCE_ID, Vector2i(0,0))


func _check_pixie_tiles():
	pixie_circle_1_tiles = base_layer.get_used_cells_by_id(2, Vector2i(0,0))
	pixie_circle_2_tiles = base_layer.get_used_cells_by_id(2, Vector2i(0,4))
	pixie_circle_3_tiles = base_layer.get_used_cells_by_id(2, Vector2i(0,8))
	pixie_hazard_tiles = hazard_layer.get_used_cells_by_id(10, Vector2i(0,0))


func _get_adjacent_empty_cell(pos) -> Vector2i:
	var attempts := 25
	var target_pos: Vector2i
	while attempts > 0:
		attempts -= 1
		var roll := randi() % 4
		print(pos)
		match roll:
			0: target_pos = pos + Vector2i(-1,0)
			1: target_pos = pos + Vector2i(0,1)
			2: target_pos = pos + Vector2i(-1,2)
			3: target_pos = pos + Vector2i(-2,1)
		
		if hazard_layer.get_cell_tile_data(target_pos + Vector2i(1,-1)) != null:
			continue
		if base_layer.get_cell_tile_data(target_pos + Vector2i(0,0)) == null:
			continue
		if base_layer.get_cell_tile_data(target_pos) != null:
			if !base_layer.get_cell_tile_data(target_pos).get_custom_data("empty"):
				continue
		return target_pos
	return Vector2i(-1000,-1000)
