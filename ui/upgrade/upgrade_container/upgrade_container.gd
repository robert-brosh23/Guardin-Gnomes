class_name UpgradeContainer
extends MarginContainer

@export var grid_container: GridContainer

var upgrade_menu: UpgradeMenu

var upgrades: Array[UpgradeData.UpgradeType]

func _ready():
	upgrade_menu = get_tree().get_first_node_in_group("upgrade_menu")
	upgrade_menu.chosen.connect(add_upgrade)

func add_upgrade(upgrade_data: UpgradeData):
	var upgrade = Upgrade.create_upgrade(upgrade_data)
	grid_container.add_child(upgrade)
	upgrades.append(upgrade.upgrade_data.type)

func check_if_has(upgrade_type: UpgradeData.UpgradeType) -> bool:
	return upgrades.has(upgrade_type)
