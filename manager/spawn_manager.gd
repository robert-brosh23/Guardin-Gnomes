class_name SpawnManager
extends Node

@onready var main: Main = get_parent()
@onready var pixie_manager: PixieManager = $"../PixieManager"
@onready var tilemap_manager: Node2D = $"../TilemapManager"
var gnome_scene: PackedScene = preload("uid://rxqd0wxka5o6")
@onready var event_label: Label = $"../CanvasLayer/GameplayArea/EventLabel"

class Coin:
	static func create_coin(_gridpos: Vector2i, _rounds_left: int) -> Coin:
		var coin = Coin.new()
		coin.grid_pos = _gridpos
		coin.rounds_left = _rounds_left
		return coin
	
	var grid_pos: Vector2i
	var rounds_left: int

const HAZARD_TILE_IDS := {
	"tornado": 1,
	"wall": 2,
	"teleporter": 3,
	"rock": 4,
	"thornbush": 5,
	"coin": 6
}

var HAZARD_INITIAL_SPAWN_QTY: Dictionary = {
	"tornado" = 2,
	"wall" = 0,
	"rock" = 2,
	"thornbush" = 2,
	"coin" = 2
}

var event_list: Dictionary = {
	"Rockslide": func(): _spawn_custom_hazards({"rock": main.EVENT_INTENSITY}),
	"Bramblegrowth": func(): _spawn_custom_hazards({"thornbush": main.EVENT_INTENSITY}),
	"Windstorm": func(): _spawn_custom_hazards({"tornado": 2}),
	"Pixie Swarm": func(): for i in main.round_counter/10: pixie_manager.pixie_rand_spawn(),
	"Make It Rain": func(): 
		for i in range(0,main.round_counter / 10 + 2):
			spawn_coin()
}

func spawn_gnome(color: Gnome.GnomeColor, grid_pos: Vector2i, direction: Gnome.Direction):
	var gnome = gnome_scene.instantiate() as Gnome
	gnome.color = color
	gnome.grid_pos = grid_pos
	gnome.direction = direction
	tilemap_manager.gnome_instances.add_child(gnome)
	return gnome
	
	
func spawn_initial_hazards():
	var tele_pos = tilemap_manager.teleporter_coords
	for i in 2:
		tilemap_manager.hazard_layer.set_cell(tele_pos[i], HAZARD_TILE_IDS["teleporter"], Vector2i(0,0))
	for hazard_type in HAZARD_INITIAL_SPAWN_QTY.keys():
		var count: int = HAZARD_INITIAL_SPAWN_QTY[hazard_type]
		var tile_id: int = HAZARD_TILE_IDS[hazard_type]
		
		for i in count:
			var pos: Vector2i
			var atlas_coords: Vector2i = _generate_atlas_for_hazard(hazard_type)
			pos = tilemap_manager.get_random_empty_cell()
#			if hazard_type == "teleporter":
#				pos = tilemap_manager.get_random_empty_portal_cell()
#				if pos == Vector2i(-1000,-1000):
#					return
#				tilemap_manager.teleporter_coords.append(pos)
#			else:
#				pos = tilemap_manager.get_random_empty_cell()
#			if pos == Vector2i(-1000,-1000):
#				return
			tilemap_manager.hazard_layer.set_cell(pos, tile_id, atlas_coords)
			if hazard_type == "coin":
				GameManager.coins_in_world.append(Coin.create_coin(pos, 5))


func _spawn_custom_hazards(hazard_spawn_qty: Dictionary):
	for hazard_type in hazard_spawn_qty.keys():
		var count: int = hazard_spawn_qty[hazard_type]
		var tile_id: int = HAZARD_TILE_IDS[hazard_type]

		for i in count:
			var pos: Vector2i
			var atlas_coords: Vector2i = _generate_atlas_for_hazard(hazard_type)
			pos = tilemap_manager.get_random_empty_cell()
			if pos == null:
				return
			tilemap_manager.hazard_layer.set_cell(pos, tile_id, atlas_coords)
			if hazard_type == "coin":
				GameManager.coins_in_world.append(Coin.create_coin(pos, 3))


func spawn_coin():
	_spawn_custom_hazards({"coin": 1})


func _generate_atlas_for_hazard(hazard_type) -> Vector2i:
	match hazard_type:
		"tornado":
			return _get_random_tornado()
		"wall":
			return _get_random_wall()
		_:
			return Vector2i(0,0)


func _get_random_tornado():
	var roll := randi() % 2
	match roll:
		0: return Vector2i(0,0)
		1: return Vector2i(0,2)


func _get_random_wall():
	var roll := randi() % 3
	match roll:
		0: return Vector2i(0,0)
		1: return Vector2i(1,0)
		2: return Vector2i(2,0)


func trigger_random_event():
	var keys = event_list.keys()
	var event_name = keys.pick_random()
	var event_func: Callable = event_list[event_name]
	
	await get_tree().create_timer(2.5).timeout
	for i in 3:
		event_label.text = "EVENT: " + event_name.to_upper()
		event_label.visible = true
		await get_tree().create_timer(0.5).timeout
		event_label.visible = false
		await get_tree().create_timer(0.25).timeout
	
	event_func.call()
