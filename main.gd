class_name Main
extends Node2D

##### BALANCING VARIABLES #####
var MAX_BLIGHT: int = 8 # how many blight allowed before game over

var PIXIE_INITIAL_SPAWN: int = 2 # how many pixie circles are at game start
var PIXIE_GROW_RATE: int = 1 # how many rounds between each pixie growth
var PIXIE_SPREAD_RATE: int = 1 # how many rounds between each pixie spread
var PIXIE_SPAWN_RATE: int = 1 # how many rounds between each pixie rand spawn
var PIXIE_SPAWN_SCALE: int = 10 # how many rounds before spawn uptick
var PIXIE_SPAWN_INTENSITY: int = 1 # how many pixies spawned at a time

var EVENT_FREQ: int = 5 # how often do events occur
var EVENT_INTENSITY: int = 30 # how many items are spawned by events
var EVENT_INTENSITY_SCALING: int = 5 # how many rounds before each intensity uptick
###############################

@export var base_layer: TileMapLayer
@export var hazard_layer: TileMapLayer
var gnomes: Array[Gnome]
const gnome_scene = preload("uid://bffr6n4g2h0d3")

@onready var pixie_manager: Node = $PixieManager
@onready var spawn_manager: Node = $SpawnManager
@onready var tilemap_manager: Node2D = $TilemapManager
@onready var hand: Hand = %Hand
@onready var game_ui: Control = %GameUI
@onready var event_countdown_label: Label = $CanvasLayer/GameUI/VBoxContainer/EventCountdownLabel
@onready var blight_label: Label = $CanvasLayer/GameUI/BlightLabel
@onready var round_label: Label = $CanvasLayer/GameUI/VBoxContainer/RoundLabel


var round_counter: int = 1


func _ready():
	_spawn_gnome_in_world(Gnome.GnomeColor.RED, Vector2i(5,5), gnome_scene.Direction.UP_LEFT)
	_spawn_gnome_in_world(Gnome.GnomeColor.BLUE, Vector2i(7,7), gnome_scene.Direction.UP_RIGHT)
	_spawn_gnome_in_world(Gnome.GnomeColor.GREEN, Vector2i(8,8), gnome_scene.Direction.DOWN_LEFT)
	
	spawn_manager.spawn_initial_hazards()
	for i in PIXIE_INITIAL_SPAWN:
		pixie_manager.pixie_rand_spawn()
	GameManager.game_state = GameManager.GameState.MANIPULATING
	SignalBus.turn_end.connect(_on_turn_end)

	round_label.text = "ROUND: %s" % round_counter
	event_countdown_label.text = "Next Event In %s Rounds" % \
		(EVENT_FREQ - (round_counter % EVENT_FREQ)) # dif from turn on purpose
	blight_label.text = "BLIGHT: %s/%s" % [0, MAX_BLIGHT]


func _on_turn_end():
	pixie_manager._on_next_round()
	_check_gameover()
	hand._on_turn_end()
	if round_counter % EVENT_FREQ == 0:
		spawn_manager.trigger_random_event()
	event_countdown_label.text = "Next Event In %s Rounds" % \
		(EVENT_FREQ - (round_counter % EVENT_FREQ) - 1)
	round_counter += 1
	round_label.text = "ROUND: %s" % round_counter


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


func _check_gameover():
	return pixie_manager.blight_count >= MAX_BLIGHT or gnomes.size() <= 0
