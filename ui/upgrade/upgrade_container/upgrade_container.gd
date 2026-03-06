class_name UpgradeContainer
extends MarginContainer

@export var grid_container: GridContainer

var upgrade_menu: UpgradeMenu

func _ready():
	upgrade_menu = get_tree().get_first_node_in_group("upgrade_menu")
	upgrade_menu.chosen.connect(add_upgrade)

func add_upgrade(upgrade_data: UpgradeData):
	if upgrade_data == null:
		return
	var upgrade = Upgrade.create_upgrade(upgrade_data)
	grid_container.add_child(upgrade)
	GameManager.upgrades.append(upgrade.upgrade_data.type)
