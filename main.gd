class_name Main
extends Node2D

@export var base_layer: TileMapLayer
@export var hazard_layer: TileMapLayer
@export var gnomes: Array[Gnome]

@onready var fairy_manager: RoundManager = %FairyManager
@onready var tile_map_layers: Node2D = %TileMapLayers


func _ready():
	for gnome in gnomes:
		gnome.global_position = base_layer.map_to_local(gnome.grid_pos) + base_layer.global_position
		gnome.try_move.connect(_try_move_piece)
		# tile_map_layers.spawn_custom_hazards({"rock": 20}) - can create big spawn events like this


func _try_move_piece(piece: Gnome, new_pos: Vector2i):
	var base_tile_data = base_layer.get_cell_tile_data(new_pos + Vector2i(-1, 1))
	print(new_pos)
	if base_tile_data == null:
		return
	
	var new_base_tile_data = base_layer.get_cell_tile_data(new_pos + Vector2i(-1,1))
	var current_base_tile_data = base_layer.get_cell_tile_data(piece.grid_pos + Vector2i(-1,1))
	var new_base_type: String
	var current_base_type: String
	var new_hazard_tile_data = hazard_layer.get_cell_tile_data(new_pos)
	var current_hazard_tile_data = hazard_layer.get_cell_tile_data(piece.grid_pos)
	var new_hazard_type: String
	var current_hazard_type: String

	if current_base_tile_data != null:
		current_base_type = current_base_tile_data.get_custom_data("base_type")
	if new_base_tile_data != null:
		new_base_type = new_base_tile_data.get_custom_data("base_type")
	if current_hazard_tile_data != null:
		current_hazard_type = current_hazard_tile_data.get_custom_data("hazard_type")
	if new_hazard_tile_data != null:
		new_hazard_type = new_hazard_tile_data.get_custom_data("hazard_type")
	
	# Handle base tiles
	if new_base_type == "fairy1" || new_base_type == "fairy2":
		#base_layer.erase_cell(new_pos + Vector2i(-1,1))
		base_layer.set_cell(new_pos + Vector2i(-1,1), 1, tile_map_layers.get_random_grass())
	
	if current_base_type == "fairy1" || current_base_type == "fairy2":
		#base_layer.erase_cell(piece.grid_pos + Vector2i(-1,1))
		base_layer.set_cell(piece.grid_pos + Vector2i(-1,1), 1, tile_map_layers.get_random_grass())

	
	# Handle hazards / move
	if new_hazard_type == "rock": return
	if _handle_wall(piece, new_hazard_type, current_hazard_type): return
	if _handle_thornbush(piece, new_hazard_type, current_hazard_type): return
	
	var new_physical_pos := base_layer.map_to_local(new_pos) + base_layer.global_position
	piece.move_to_space(new_pos, new_physical_pos)
	
	if new_hazard_type == "pixie":
		await get_tree().create_timer(0.7).timeout # makes it look like gnome stomped pixie
		hazard_layer.erase_cell(new_pos)
		# notify xp system that a pixie was removed
		# notify base layer to stop spawning more
	_handle_teleporter(piece, new_hazard_type)
	if new_hazard_type == "tornado_right": piece.turn_right()
	if new_hazard_type == "tornado_left": piece.turn_left()


func _handle_wall(piece, new_hazard_type, current_hazard_type):
	if new_hazard_type == "wall_left" && piece.direction == piece.Direction.UP_RIGHT:
		return true
	if new_hazard_type == "wall_right" && piece.direction == piece.Direction.UP_LEFT:
		return true
	if new_hazard_type == "wall_corner" && (piece.direction == piece.Direction.UP_LEFT || \
		piece.direction == piece.Direction.UP_RIGHT):
		return true
	if current_hazard_type == "wall_left" && piece.direction == piece.Direction.DOWN_LEFT:
		return true
	if current_hazard_type == "wall_right" && piece.direction == piece.Direction.DOWN_RIGHT:
		return true
	if current_hazard_type == "wall_corner" && (piece.direction == piece.Direction.DOWN_LEFT || \
		piece.direction == piece.Direction.DOWN_RIGHT):
		return true


func _handle_thornbush(piece, new_hazard_type, current_hazard_type):
	if new_hazard_type == "thorn_bush": piece.stuck_count = 1
	if current_hazard_type == "thorn_bush":
		if piece.stuck_count > 0:
			piece.stuck_count -= 1
			return true


func _handle_teleporter(piece, new_hazard_type):
	if new_hazard_type == "teleporter":
		await get_tree().create_timer(0.81).timeout
		
		var current_pos = piece.grid_pos
		var target_pos: Vector2i
		for pos in tile_map_layers.teleporter_coords:
			if pos != current_pos:
				target_pos = pos
				break
		
		var target_physical_pos = base_layer.map_to_local(target_pos) + base_layer.global_position
		piece.grid_pos = target_pos
		piece.global_position = target_physical_pos
		
		piece.try_move_forward()
		return
