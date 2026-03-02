extends Node2D

@onready var base_layer: TileMapLayer = $BaseLayer
@onready var hazard_layer: TileMapLayer = $HazardLayer
@onready var gnome: Gnome = $Gnome
@onready var main: Main = get_parent().get_parent()

var teleporter_coords: Array[Vector2i]

var HAZARD_TILE_IDS := {
	"tornado": 1,
	"wall": 2,
	"teleporter": 3,
	"rock": 4,
	"thornbush": 5
}

var HAZARD_INITIAL_SPAWN_QTY: Dictionary = {
	"tornado" = 2,
	"wall" = 6,
	"rock" = 4,
	"thornbush" = 4,
	"teleporter" = 2
}

func _ready() -> void:
	randomize()
	spawn_initial_hazards()
	for i in 2: spawn_fairy_circle()


func spawn_initial_hazards():
	for hazard_type in HAZARD_INITIAL_SPAWN_QTY.keys():
		var count: int = HAZARD_INITIAL_SPAWN_QTY[hazard_type]
		var tile_id: int = HAZARD_TILE_IDS[hazard_type]
		
		for i in count:
			var pos: Vector2i
			var atlas_coords: Vector2i = _generate_atlas_for_hazard(hazard_type)
			if hazard_type == "teleporter":
				pos = _get_random_empty_portal_cell()
				if pos == Vector2i(-1000,-1000):
					return
				teleporter_coords.append(pos)
			else:
				pos = get_random_empty_cell()
			if pos == Vector2i(-1000,-1000):
				return
			hazard_layer.set_cell(pos, tile_id, atlas_coords)


func spawn_fairy_circle():
	var pos: Vector2i = get_random_empty_cell()
	if pos != Vector2i(-1000,-1000):
		pos = pos + Vector2i(-1,1)
		base_layer.set_cell(pos, 2, Vector2i(0,0))


func spawn_custom_hazards(hazard_spawn_qty: Dictionary):
	for hazard_type in hazard_spawn_qty.keys():
		var count: int = hazard_spawn_qty[hazard_type]
		var tile_id: int = HAZARD_TILE_IDS[hazard_type]
		
		for i in count:
			var pos: Vector2i
			var atlas_coords: Vector2i = _generate_atlas_for_hazard(hazard_type)
			pos = get_random_empty_cell()
			if pos == null:
				return
			hazard_layer.set_cell(pos, tile_id, atlas_coords)


func _get_random_empty_portal_cell() -> Vector2i:
	var attempts := 100
	while attempts > 0:
		attempts -= 1
		var x := randi_range(2, 11)
		var y := randi_range(0, 9)
		var pos := Vector2i(x, y)
		if hazard_layer.get_cell_tile_data(pos) != null:
			continue
		var occupied_by_gnome := false
		for gnome in main.gnomes:
			if gnome.grid_pos == pos:
				occupied_by_gnome = true
				break
		if occupied_by_gnome:
			continue
			
		return pos
	return Vector2i(-1000,-1000)
	

func get_random_empty_cell() -> Vector2i:
	var attempts := 1000
	while attempts > 0:
		attempts -= 1
		var x := randi_range(1, 12)
		var y := randi_range(-1, 10)
		var pos := Vector2i(x, y)
		if hazard_layer.get_cell_tile_data(pos) != null:
			continue
		if !base_layer.get_cell_tile_data(pos + Vector2i(-1,1)).get_custom_data("empty"):
			continue
		var occupied_by_gnome := false
		for gnome in main.gnomes:
			if gnome.grid_pos == pos:
				occupied_by_gnome = true
				break
		if occupied_by_gnome:
			continue
			
		return pos
	return Vector2i(-1000,-1000)


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


func get_random_grass():
	var x := randi() % 6
	return Vector2i(x,1)
