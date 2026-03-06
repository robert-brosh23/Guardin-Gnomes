extends Node

enum GameState {ENCHANTING, MANIPULATING, DRAWING, DISCARDING}

var game_state: GameState

var upgrades: Array[UpgradeData.UpgradeType]

func check_if_has(upgrade_type: UpgradeData.UpgradeType) -> bool:
	return upgrades.has(upgrade_type)

var coins_required_for_upgrade : Array[int] = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 999]
var num_coins: int = 0

func get_required_coins() -> int:
	return coins_required_for_upgrade.get(upgrades.size())
