extends Node2D


@export var gnomes: Array[Gnome]
@export var base_layer: TileMapLayer
@export var hazard_layer: TileMapLayer

@onready var gnome_instances: Node2D = $GnomeInstances
@onready var main: Main = get_parent()

var teleporter_coords: Array[Vector2i] = [Vector2i(3,1), Vector2i(10,8)]


func get_random_empty_portal_cell() -> Vector2i:
	var attempts := 100
	while attempts > 0:
		attempts -= 1
		var x := randi_range(2, 11)
		var y := randi_range(0, 9)
		var pos := Vector2i(x, y)
		if hazard_layer.get_cell_tile_data(pos) != null:
			continue
		var occupied_by_gnome := false
		for piece in main.gnomes:
			if piece.grid_pos == pos:
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
		
		
		print("I am:", self)
		print("My parent:", get_parent())
		print(hazard_layer)
		
		# check that there isn't a hazard there
		if hazard_layer.get_cell_tile_data(pos) != null:
			continue
		
		# check if it's an open block ('empty' custom bool is assigned to whitelisted blocks)
		if !base_layer.get_cell_tile_data(pos + Vector2i(-1,1)).get_custom_data("empty"):
			continue
		
		# check that there isn't a gnome there
		var occupied_by_gnome := false
		for piece in main.gnomes:
			if piece.grid_pos == pos:
				occupied_by_gnome = true
				break
		if occupied_by_gnome:
			continue
		
		return pos
	return Vector2i(-1000,-1000)


func get_random_grass():
	var x := randi() % 6
	return Vector2i(x,1)


func get_adjacent_empty_cell(pos) -> Vector2i:
	var attempts := 25
	var target_pos: Vector2i
	while attempts > 0:
		attempts -= 1
		var roll := randi() % 4
		print(pos)
		match roll:
			0: target_pos = pos + Vector2i(-1,0)
			1: target_pos = pos + Vector2i(0,1)
			2: target_pos = pos + Vector2i(-1,2)
			3: target_pos = pos + Vector2i(-2,1)
		
		if hazard_layer.get_cell_tile_data(target_pos + Vector2i(1,-1)) != null:
			continue
		if base_layer.get_cell_tile_data(target_pos + Vector2i(0,0)) == null:
			continue
		if base_layer.get_cell_tile_data(target_pos) != null:
			if !base_layer.get_cell_tile_data(target_pos).get_custom_data("empty"):
				continue
		return target_pos
	return Vector2i(-1000,-1000)
