extends Node

@onready var pixie_manager: PixieManager = $"../PixieManager"
@onready var tilemap_manager: Node2D = $"../TilemapManager"
var gnome_scene: PackedScene = preload("uid://rxqd0wxka5o6")

const HAZARD_TILE_IDS := {
	"tornado": 1,
	"wall": 2,
	"teleporter": 3,
	"rock": 4,
	"thornbush": 5
}

var HAZARD_INITIAL_SPAWN_QTY: Dictionary = {
	"tornado" = 4,
	"wall" = 6,
	"rock" = 6,
	"thornbush" = 6,
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


func event_rock():
	_spawn_custom_hazards({"rock": 4})


func event_thornbush():
	_spawn_custom_hazards({"thornbush": 4})


func event_tornado():
	_spawn_custom_hazards({"tornado": 4})


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


func _generate_atlas_for_hazard(hazard_type) -> Vector2i:
	match hazard_type:
		"tornado":
			return _get_random_tornado()
		"wall":
			return _get_random_wall()
		_:
			return Vector2i(0,0)


func _get_random_tornado(): # don't judge me Robert, I know it's hardcoded spaghetti
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
