class_name PixieManager
extends Node

@onready var tilemap_manager: Node = $"../TilemapManager"
@onready var base_layer: TileMapLayer = $"../TilemapManager/BaseLayer"
@onready var hazard_layer: TileMapLayer = $"../TilemapManager/HazardLayer"
@onready var main: Main = get_parent()
@export var blight_label: Label


# initializations
const PIXIE_CIRCLE_SOURCE_ID := 2
const PIXIE_HAZARD_SOURCE_ID := 10
const PIXIE_CIRCLE_1_ATLAS := Vector2i(0,0)
const PIXIE_CIRCLE_2_ATLAS := Vector2i(0,4)
const PIXIE_CIRCLE_3_ATLAS := Vector2i(0,8)
const PIXIE_CIRCLE_4_ATLAS := Vector2i(0,12)
const PIXIE_CIRCLE_5_ATLAS := Vector2i(0,16)
const PIXIE_HAZARD_ATLAS := Vector2i(0,0)

var pixie_circle_1_tiles: Array[Vector2i]
var pixie_circle_2_tiles: Array[Vector2i]
var pixie_circle_3_tiles: Array[Vector2i]
var pixie_circle_4_tiles: Array[Vector2i]
var pixie_circle_5_tiles: Array[Vector2i]
var pixie_hazard_tiles: Array[Vector2i]

var blight_count: int


func _on_next_round(_round_number := 0):
	if main.round_counter % main.PIXIE_GROW_RATE == 0:
		pixie_grow()
	if main.round_counter % main.PIXIE_SPREAD_RATE == 0:
		pixie_spread()
	if main.round_counter % main.PIXIE_SPAWN_RATE == 0:
		for i in main.PIXIE_SPAWN_INTENSITY: pixie_rand_spawn()
	if main.round_counter % main.PIXIE_SPAWN_SCALE == 0:
		if main.PIXIE_SPAWN_RATE >= 2:
			main.PIXIE_SPAWN_RATE -= 1
		else:
			main.PIXIE_SPAWN_INTENSITY += 1

	_check_pixie_tiles()
	blight_count = pixie_circle_5_tiles.size()
	blight_label.text = "Blight: %s/%s" % [blight_count, main.MAX_BLIGHT]


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
	for tile_pos in pixie_circle_3_tiles:
		base_layer.set_cell(tile_pos, PIXIE_CIRCLE_SOURCE_ID, Vector2i(0,12))
	for tile_pos in pixie_circle_4_tiles:
		base_layer.set_cell(tile_pos, PIXIE_CIRCLE_SOURCE_ID, Vector2i(0,16))
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
	pixie_circle_4_tiles = base_layer.get_used_cells_by_id(PIXIE_CIRCLE_SOURCE_ID, PIXIE_CIRCLE_4_ATLAS)
	pixie_circle_5_tiles = base_layer.get_used_cells_by_id(PIXIE_CIRCLE_SOURCE_ID, PIXIE_CIRCLE_5_ATLAS)
	pixie_hazard_tiles = hazard_layer.get_used_cells_by_id(PIXIE_HAZARD_SOURCE_ID, PIXIE_HAZARD_ATLAS)
	
	
func get_pixie_circles() -> Array[Vector2i]:
	pixie_circle_1_tiles = base_layer.get_used_cells_by_id(PIXIE_CIRCLE_SOURCE_ID, PIXIE_CIRCLE_1_ATLAS)
	pixie_circle_2_tiles = base_layer.get_used_cells_by_id(PIXIE_CIRCLE_SOURCE_ID, PIXIE_CIRCLE_2_ATLAS)
	pixie_circle_3_tiles = base_layer.get_used_cells_by_id(PIXIE_CIRCLE_SOURCE_ID, PIXIE_CIRCLE_3_ATLAS)
	pixie_circle_4_tiles = base_layer.get_used_cells_by_id(PIXIE_CIRCLE_SOURCE_ID, PIXIE_CIRCLE_4_ATLAS)
	return pixie_circle_1_tiles + pixie_circle_2_tiles + pixie_circle_3_tiles + pixie_circle_4_tiles
