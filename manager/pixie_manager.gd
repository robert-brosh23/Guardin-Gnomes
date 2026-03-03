class_name PixieManager
extends Node

@onready var tilemap_manager: Node = $"../TilemapManager"
@onready var base_layer: TileMapLayer = $"../TilemapManager/BaseLayer"
@onready var hazard_layer: TileMapLayer = $"../TilemapManager/HazardLayer"


const PIXIE_CIRCLE_SOURCE_ID := 2
const PIXIE_HAZARD_SOURCE_ID := 10
const PIXIE_CIRCLE_1_ATLAS := Vector2i(0,0)
const PIXIE_CIRCLE_2_ATLAS := Vector2i(0,4)
const PIXIE_CIRCLE_3_ATLAS := Vector2i(0,8)
const PIXIE_HAZARD_ATLAS := Vector2i(0,0)

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
	var target_pos = tilemap_manager.get_random_empty_cell()
	if target_pos != Vector2i(-1000,-1000):
		base_layer.set_cell(target_pos + Vector2i(-1,1), PIXIE_CIRCLE_SOURCE_ID, Vector2i(0,0))


func pixie_grow():
	_check_pixie_tiles()
	for tile_pos in pixie_circle_1_tiles:
		base_layer.set_cell(tile_pos, PIXIE_CIRCLE_SOURCE_ID, Vector2i(0,4))
	for tile_pos in pixie_circle_2_tiles:
		base_layer.set_cell(tile_pos, PIXIE_CIRCLE_SOURCE_ID, Vector2i(0,8))
		hazard_layer.set_cell(tile_pos + Vector2i(1,-1), PIXIE_HAZARD_SOURCE_ID, Vector2i(0,0))


func pixie_spread():
	for tile_pos in pixie_hazard_tiles:
		var target_pos = tilemap_manager.get_adjacent_empty_cell(tile_pos)
		if target_pos != Vector2i(-1000,-1000):
			base_layer.set_cell(target_pos, PIXIE_CIRCLE_SOURCE_ID, Vector2i(0,0))


func _check_pixie_tiles():
	pixie_circle_1_tiles = base_layer.get_used_cells_by_id(PIXIE_CIRCLE_SOURCE_ID, PIXIE_CIRCLE_1_ATLAS)
	pixie_circle_2_tiles = base_layer.get_used_cells_by_id(PIXIE_CIRCLE_SOURCE_ID, PIXIE_CIRCLE_2_ATLAS)
	pixie_circle_3_tiles = base_layer.get_used_cells_by_id(PIXIE_CIRCLE_SOURCE_ID, PIXIE_CIRCLE_3_ATLAS)
	pixie_hazard_tiles = hazard_layer.get_used_cells_by_id(PIXIE_HAZARD_SOURCE_ID, PIXIE_HAZARD_ATLAS)
