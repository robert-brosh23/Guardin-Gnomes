class_name Main
extends Node2D

@export var base_layer: TileMapLayer
@export var hazard_layer: TileMapLayer
var gnomes: Array[Gnome]
const gnome_scene = preload("uid://bffr6n4g2h0d3")

@onready var pixie_manager: Node = $PixieManager
@onready var spawn_manager: Node = $SpawnManager
@onready var tilemap_manager: Node2D = $TilemapManager


func _ready():
	_spawn_gnome_in_world(Gnome.GnomeColor.RED, Vector2i(5,5), gnome_scene.Direction.UP_LEFT)
	_spawn_gnome_in_world(Gnome.GnomeColor.BLUE, Vector2i(7,7), gnome_scene.Direction.UP_RIGHT)
	_spawn_gnome_in_world(Gnome.GnomeColor.GREEN, Vector2i(8,8), gnome_scene.Direction.DOWN_LEFT)
		
	spawn_manager.spawn_initial_hazards()
		
#	spawn_manager.event_tornado()
#	spawn_manager.event_rock()
#	spawn_manager.event_thornbush()


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
	
	
	# Handle hazards / move
	if new_hazard_type == "rock": return
	if _handle_wall(piece, new_hazard_type, current_hazard_type): return
	if _handle_thornbush(piece, new_hazard_type, current_hazard_type): return
	
	var new_physical_pos := base_layer.map_to_local(new_pos) + base_layer.global_position
	piece.move_to_space(new_pos, new_physical_pos)


	if new_hazard_type == "pixie":
		await get_tree().create_timer(0.8).timeout # purely for visuals
		hazard_layer.erase_cell(new_pos)
		# notify xp system that a pixie was removed
	_handle_teleporter(piece, new_hazard_type)
	if new_hazard_type == "tornado_right": piece.turn_right()
	if new_hazard_type == "tornado_left": piece.turn_left()


	# Handle base tiles
	if new_base_type == "fairy1" || new_base_type == "fairy2":
		await get_tree().create_timer(0.8).timeout # purely for visuals
		base_layer.set_cell(new_pos + Vector2i(-1,1), 1, tilemap_manager.get_random_grass())
	
	if current_base_type == "fairy1" || current_base_type == "fairy2":
		await get_tree().create_timer(0.8).timeout # purely for visuals
		base_layer.set_cell(piece.grid_pos + Vector2i(-1,1), 1, tilemap_manager.get_random_grass())


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
		await get_tree().create_timer(0.82).timeout
		
		var current_pos = piece.grid_pos
		var target_pos: Vector2i
		for pos in tilemap_manager.teleporter_coords:
			if pos != current_pos:
				target_pos = pos
				break
		
		var target_physical_pos = base_layer.map_to_local(target_pos) + base_layer.global_position
		piece.grid_pos = target_pos
		piece.global_position = target_physical_pos
		piece.try_move_forward()
		return


func _spawn_gnome_in_world(color: Gnome.GnomeColor, grid_pos: Vector2i, direction):
	var gnome = spawn_manager.spawn_gnome(color, grid_pos, direction)
	gnome.global_position = base_layer.map_to_local(gnome.grid_pos) + base_layer.global_position
	gnome.try_move.connect(_try_move_piece)
	gnomes.append(gnome)
