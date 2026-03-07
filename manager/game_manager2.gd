extends Node

enum GameState {ENCHANTING, MANIPULATING, DRAWING, DISCARDING}

var game_state: GameState
var main: Main
var upgrades: Array[UpgradeData.UpgradeType]
var coins_required_for_upgrade : Array[int] = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 999]
var num_coins: int = 0
var coins_in_world: Array[SpawnManager.Coin]

func _ready() -> void:
	main = get_tree().get_first_node_in_group("main")
	SignalBus.turn_end.connect(_update_coins)

func check_if_has(upgrade_type: UpgradeData.UpgradeType) -> bool:
	return upgrades.has(upgrade_type)
	
func get_required_coins() -> int:
	return coins_required_for_upgrade.get(upgrades.size())
	
func _update_coins():
	for coin in coins_in_world:
		coin.rounds_left -= 1
		if coin.rounds_left == 1:
			main.hazard_layer.get_cell_tile_data(coin.grid_pos).set_custom_data("blink", true)
		if coin.rounds_left <= 0:
			main.hazard_layer.set_cell(coin.grid_pos, 1)
			coins_in_world.erase(coin)

func remove_coin_at_pos(grid_pos: Vector2i) -> bool:
	for coin in coins_in_world:
		if coin.grid_pos == grid_pos:
			coins_in_world.erase(coin)
			return true
	return false
