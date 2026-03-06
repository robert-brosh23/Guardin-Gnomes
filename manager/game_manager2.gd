extends Node

enum GameState {ENCHANTING, MANIPULATING, DRAWING, DISCARDING}

var game_state: GameState

var upgrades: Array[UpgradeData.UpgradeType]

func check_if_has(upgrade_type: UpgradeData.UpgradeType) -> bool:
	return upgrades.has(upgrade_type)
