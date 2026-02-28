class_name Main
extends Node2D

@export var base_layer: TileMapLayer
@export var harard_layer: TileMapLayer

@export var gnomes: Array[Gnome]

func _ready():
	for gnome in gnomes:
		gnome.global_position = base_layer.map_to_local(gnome.grid_pos) + base_layer.global_position
		gnome.try_move.connect(_try_move_piece)

func _try_move_piece(piece: Gnome, new_pos: Vector2i):
	var base_tile_data = base_layer.get_cell_tile_data(new_pos + Vector2i(-1, 1))
	print(new_pos)
	if base_tile_data == null:
		return
	
	var hazard_tile_data = harard_layer.get_cell_tile_data(new_pos)
	if hazard_tile_data != null:
		if hazard_tile_data.get_custom_data("wall"):
			return
		
	piece.global_position = base_layer.map_to_local(new_pos) + base_layer.global_position
	piece.move_to_space(new_pos)
