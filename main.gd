class_name Main
extends Node2D

@export var base_layer: TileMapLayer
@export var gnomes: Array[Gnome]

func _ready():
	for gnome in gnomes:
		gnome.global_position = base_layer.map_to_local(gnome.grid_pos) + base_layer.global_position + Vector2(0, -24)
		gnome.try_move.connect(_try_move_piece)

func _try_move_piece(piece: Gnome, new_pos: Vector2i):
	var tile_data = base_layer.get_cell_tile_data(new_pos)
	print(new_pos)
	if tile_data == null:
		return
		
	piece.global_position = base_layer.map_to_local(new_pos) + base_layer.global_position + Vector2(0, -24)
	piece.move_to_space(new_pos)
	
func get_tile_data(grid_pos: Vector2i):
	var x = base_layer.get_cell_tile_data(grid_pos)
	var y = base_layer.get_used_cells()
	print("")
	
