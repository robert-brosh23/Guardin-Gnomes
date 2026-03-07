class_name Main
extends Node2D

##### BALANCING VARIABLES #####
var MAX_BLIGHT: int = 8 # how many blight allowed before game over

var PIXIE_INITIAL_SPAWN: int = 2 # how many pixie circles are at game start
var PIXIE_GROW_RATE: int = 2 # how many rounds between each pixie growth
var PIXIE_SPREAD_RATE: int = 1 # how many rounds between each pixie spread
var PIXIE_SPAWN_RATE: int = 2 # how many rounds between each pixie rand spawn
var PIXIE_SPAWN_SCALE: int = 10 # how many rounds before spawn uptick
var PIXIE_SPAWN_INTENSITY: int = 1 # how many pixies spawned at a time

var EVENT_FREQ: int = 5 # how often do events occur
var EVENT_INTENSITY: int = 5 # how many items are spawned by events
var EVENT_INTENSITY_SCALING: int = 5 # how many rounds before each intensity uptick

var COIN_FREQ: int = 1 # how many rounds between each coin spawn
var COIN_SCALE: int = 15 # how many rounds between coin spawn increase
###############################

@export var debug_enabled: bool
@export var base_layer: TileMapLayer
@export var hazard_layer: TileMapLayer
var gnomes: Array[Gnome]
const gnome_scene = preload("uid://bffr6n4g2h0d3")

@onready var programming_track_ui: ProgrammingTrackUI = $CanvasLayer/ProgrammingTrackUI
@onready var pixie_manager: PixieManager = $PixieManager
@onready var spawn_manager: SpawnManager = $SpawnManager
@onready var tilemap_manager: Node2D = $TilemapManager
@onready var hand: Hand = %Hand
@onready var game_ui: Control = %GameUI
@export var event_countdown_label: Label
@export var blight_label: Label
@export var round_label: Label
@export var coins_to_next_label: Label

var round_counter: int = 1

var rock_destroy_sfx = preload("res://audio/Gravel Interaction A.wav")
var purify_sfx = preload("res://audio/Cozy UI D2.wav")
var coin_sfx = preload("res://audio/Cozy UI D5.wav")

func _ready():
	_spawn_gnome_in_world(Gnome.GnomeColor.RED, Vector2i(6,4), gnome_scene.Direction.DOWN_LEFT)
	_spawn_gnome_in_world(Gnome.GnomeColor.BLUE, Vector2i(7,4), gnome_scene.Direction.UP_RIGHT)
	_spawn_gnome_in_world(Gnome.GnomeColor.GREEN, Vector2i(7,5), gnome_scene.Direction.DOWN_RIGHT)
	
	spawn_manager.spawn_initial_hazards()
	for i in PIXIE_INITIAL_SPAWN:
		pixie_manager.pixie_rand_spawn()
	GameManager.game_state = GameManager.GameState.MANIPULATING
	SignalBus.turn_end.connect(_on_turn_end)

	round_label.text = "ROUND: %s" % round_counter
	event_countdown_label.text = "Next Event: " % \
		(EVENT_FREQ - (round_counter % EVENT_FREQ)) # dif from turn on purpose
	blight_label.text = "Blight: %s/%s" % [0, MAX_BLIGHT]
	event_countdown_label.text = "Next Event In %s Rounds" % \
		(EVENT_FREQ - (round_counter % EVENT_FREQ))


func _process(delta: float) -> void:
	coins_to_next_label.text = "Coins to next upgrade: " + str(GameManager.get_required_coins() - GameManager.num_coins)
	


func all_gnomes_idle():
	for gnome in gnomes:
		if !gnome.is_idle():
			return false
	return true


func _on_turn_end():
	pixie_manager._on_next_round()
	_check_gameover()
	hand._on_turn_end()
	for i in round_counter/15 + 1:
		spawn_manager.spawn_coin()
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
		piece.try_move_distance -= 1
		piece.try_move_forward(piece.try_move_distance)
		return
	
	_try_sturdy(piece, new_pos)
	
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
	
	
	var new_physical_pos := base_layer.map_to_local(new_pos) + base_layer.global_position
	
	# Handle hazards / move
	if new_hazard_type == "rock":
		piece.try_move_distance -= 1
		piece.try_move_forward(piece.try_move_distance)
		return
	
	if _handle_wall(piece, new_hazard_type, current_hazard_type):
		piece.try_move_distance -= 1
		piece.try_move_forward(piece.try_move_distance)
		return
		
	if _handle_thornbush(piece, new_hazard_type, current_hazard_type): return
	
	_try_perceptive(piece, new_pos, piece.grid_pos)
	_handle_coin(piece, new_pos, new_hazard_type)
	
	var old_pos := piece.grid_pos
	piece.move_to_space(new_pos, new_physical_pos)
	_try_powerful(piece, new_pos)

	if new_hazard_type == "pixie":
		_destroy_hazard(new_pos, "pixie")
		# notify xp system that a pixie was removed
	_handle_teleporter(piece, new_hazard_type)
	if new_hazard_type == "tornado_right": piece.turn_right()
	if new_hazard_type == "tornado_left": piece.turn_left()


	# Handle base tiles
	var fairy_tiles_to_check : Array[String] = ["fairy1", "fairy2","fairy3","fairy4"]
	if GameManager.check_if_has(UpgradeData.UpgradeType.WISE) and piece.color == Gnome.GnomeColor.BLUE:
		fairy_tiles_to_check.append("fairy5")
	
	_try_serene(piece, new_pos, old_pos, fairy_tiles_to_check)
	_range_helper(piece, new_pos, fairy_tiles_to_check)
	if fairy_tiles_to_check.has(new_base_type):
		_purify_tile(new_pos)

func _purify_tile(grid_pos: Vector2i):
	await get_tree().create_timer(0.8).timeout # purely for visuals
	var purify = Purify.create_purify()
	purify.global_position = base_layer.map_to_local(grid_pos) + base_layer.global_position
	add_child(purify)
	base_layer.set_cell(grid_pos + Vector2i(-1,1), 1, tilemap_manager.get_random_grass())
	AudioPlayer.play_sound(purify_sfx)
	GameManager.total_purified += 1
	
func _try_perceptive(gnome: Gnome, new_pos: Vector2i, old_pos: Vector2i):
	if !GameManager.check_if_has(UpgradeData.UpgradeType.PERCEPTIVE) or gnome.color != Gnome.GnomeColor.GREEN:
		return
	var points := _get_points_between(old_pos, new_pos)
	for point in points:
		var secondary_points := _get_adj_points(point)
		for secondary_point in secondary_points:
			if hazard_layer.get_cell_tile_data(secondary_point):
				var hazard_type := hazard_layer.get_cell_tile_data(secondary_point).get_custom_data("hazard_type") as String
				if hazard_type == "coin":
					_collect_coin(secondary_point)
				

func _try_serene(gnome: Gnome, new_pos: Vector2i, old_pos: Vector2i, fairy_tiles_to_check: Array[String]):
	if !((GameManager.check_if_has(UpgradeData.UpgradeType.SERENE) and gnome.color == Gnome.GnomeColor.BLUE) or (GameManager.check_if_has(UpgradeData.UpgradeType.AGILE) and gnome.color == Gnome.GnomeColor.GREEN)):
		return
	var points := _get_points_between(old_pos, new_pos)
	for point in points:
		_range_helper(gnome, point, fairy_tiles_to_check)
		if hazard_layer.get_cell_tile_data(point):
			var hazard_type := hazard_layer.get_cell_tile_data(point).get_custom_data("hazard_type") as String
			if hazard_type == "pixie":
				_destroy_hazard(point, hazard_type)
		point += + Vector2i(-1,1)
		if base_layer.get_cell_tile_data(point):
			var tile_type := base_layer.get_cell_tile_data(point).get_custom_data("base_type") as String
			if fairy_tiles_to_check.has(tile_type):
				_purify_tile(point + Vector2i(1,-1))
		
func _try_empathetic(gnome: Gnome, new_pos: Vector2i, fairy_tiles_to_check: Array[String]):
	if !GameManager.check_if_has(UpgradeData.UpgradeType.EMPATHETIC) or gnome.color != Gnome.GnomeColor.BLUE:
		return
	var points := _get_more_points(new_pos)
	for point in points:
		if hazard_layer.get_cell_tile_data(point):
			var hazard_type := hazard_layer.get_cell_tile_data(point).get_custom_data("hazard_type") as String
			if hazard_type == "pixie":
				_destroy_hazard(point, hazard_type)
		point += Vector2i(-1,1)
		if base_layer.get_cell_tile_data(point):
			var tile_type := base_layer.get_cell_tile_data(point).get_custom_data("base_type") as String
			if fairy_tiles_to_check.has(tile_type):
				_purify_tile(point + Vector2i(1,-1))

func _range_helper(gnome: Gnome, new_pos: Vector2i, fairy_tiles_to_check: Array[String]):
	var points := _get_adj_points(new_pos)
	for point in points:
		if hazard_layer.get_cell_tile_data(point):
			var hazard_type := hazard_layer.get_cell_tile_data(point).get_custom_data("hazard_type") as String
			if hazard_type == "pixie":
				_destroy_hazard(point, hazard_type)
		point += + Vector2i(-1,1)
		if base_layer.get_cell_tile_data(point):
			var tile_type := base_layer.get_cell_tile_data(point).get_custom_data("base_type") as String
			if fairy_tiles_to_check.has(tile_type):
				_purify_tile(point + Vector2i(1,-1))
		_try_empathetic(gnome, new_pos, fairy_tiles_to_check)


func _try_sturdy(gnome: Gnome, new_pos: Vector2i):
	if !GameManager.check_if_has(UpgradeData.UpgradeType.STURDY) or gnome.color != Gnome.GnomeColor.RED:
		return
	var points := _get_points_between(gnome.grid_pos, new_pos)
	for point in points:
		if hazard_layer.get_cell_tile_data(point):
			var hazard_type := hazard_layer.get_cell_tile_data(point).get_custom_data("hazard_type") as String
			if hazard_type == "rock" or hazard_type == "thorn_bush":
				_destroy_hazard(point, hazard_type)
		_try_powerful(gnome, point)


func _try_powerful(gnome: Gnome, new_pos: Vector2i):
	if !GameManager.check_if_has(UpgradeData.UpgradeType.POWERFUL) or gnome.color != Gnome.GnomeColor.RED:
		return
	var points := _get_adj_points(new_pos)
	for point in points:
		if hazard_layer.get_cell_tile_data(point):
			var hazard_type := hazard_layer.get_cell_tile_data(point).get_custom_data("hazard_type") as String
			if hazard_type == "rock" or hazard_type == "thorn_bush":
				_destroy_hazard(point, hazard_type)


func _destroy_hazard(grid_pos: Vector2i, hazard_type: String):
	hazard_layer.set_cell(grid_pos, 1)
	
	var breaker_particles := BreakerParticles.create_breaker_particles(hazard_type)
	breaker_particles.global_position = base_layer.map_to_local(grid_pos) + base_layer.global_position
	add_child(breaker_particles)
	
	if GameManager.check_if_has(UpgradeData.UpgradeType.PRACTICAL) and hazard_type == "rock":
		_collect_coin()
		
	AudioPlayer.play_sound(rock_destroy_sfx)


func _get_adj_points(grid_pos: Vector2i) -> Array[Vector2i]:
	var points: Array[Vector2i] = []
	points.append(grid_pos + Vector2i(1,0))
	points.append(grid_pos + Vector2i(-1,0))
	points.append(grid_pos + Vector2i(0,1))
	points.append(grid_pos + Vector2i(0,-1))
	return points


func _get_more_points(grid_pos: Vector2i) -> Array[Vector2i]:
	var points: Array[Vector2i] = []
	points.append(grid_pos + Vector2i(1,0))
	points.append(grid_pos + Vector2i(-1,0))
	points.append(grid_pos + Vector2i(0,1))
	points.append(grid_pos + Vector2i(0,-1))
	points.append(grid_pos + Vector2i(1,1))
	points.append(grid_pos + Vector2i(1,-1))
	points.append(grid_pos + Vector2i(-1,1))
	points.append(grid_pos + Vector2i(-1,-1))
	points.append(grid_pos + Vector2i(2,0))
	points.append(grid_pos + Vector2i(-2,0))
	points.append(grid_pos + Vector2i(0,2))
	points.append(grid_pos + Vector2i(0,-2))
	return points


## This function only works when the two points are on the same axis.
func _get_points_between(a: Vector2i, b: Vector2i) -> Array[Vector2i]:
	var points: Array[Vector2i] = []
	if a.x == b.x:
		var min_y = min(a.y, b.y)
		var max_y = max(a.y, b.y)
		for y in range(min_y, max_y + 1):
			points.append(Vector2i(a.x, y))
	elif a.y == b.y:
		var min_x = min(a.x, b.x)
		var max_x = max(a.x, b.x)
		for x in range(min_x, max_x + 1):
			points.append(Vector2i(x, a.y))
	return points


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


func _handle_thornbush(piece: Gnome, new_hazard_type, current_hazard_type):
	if new_hazard_type == "thorn_bush" and current_hazard_type != "thorn_bush": 
		piece.stuck_count = 1
		_enable_stuck_label(piece)
	if current_hazard_type == "thorn_bush":
		if piece.stuck_count > 0:
			piece.stuck_label.visible = false
			piece.stuck_count -= 1
			return true


func _enable_stuck_label(piece: Gnome):
	await get_tree().create_timer(.8).timeout
	piece.stuck_label.visible = true
	

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


func _handle_coin(piece: Gnome, grid_pos: Vector2i, new_hazard_type: String):
	if new_hazard_type == "coin":
		_collect_coin(grid_pos)
		return true


func _collect_coin(grid_pos: Vector2i = Vector2i(-999,-999)):
	if grid_pos != Vector2i(-999,-999):
		await get_tree().create_timer(0.6).timeout
		hazard_layer.erase_cell(grid_pos)
		GameManager.remove_coin_at_pos(grid_pos)
	GameManager.num_coins += 1
	GameManager.total_collected += 1
	AudioPlayer.play_sound(coin_sfx)
	if GameManager.check_if_has(UpgradeData.UpgradeType.INTELLIGENT):
		var circles_coords := pixie_manager.get_pixie_circles()
		if !circles_coords.is_empty():
			_purify_tile(circles_coords.pick_random() + Vector2i(1, -1))
			

func _spawn_gnome_in_world(color: Gnome.GnomeColor, grid_pos: Vector2i, direction):
	var gnome = spawn_manager.spawn_gnome(color, grid_pos, direction)
	gnome.global_position = base_layer.map_to_local(gnome.grid_pos) + base_layer.global_position
	gnome.try_move.connect(_try_move_piece)
	gnomes.append(gnome)


func _check_gameover():
	return pixie_manager.blight_count >= MAX_BLIGHT or gnomes.size() <= 0
