class_name UpgradeMenu
extends Control

signal chosen(data: UpgradeData)

@export var hbox_container: HBoxContainer

var preview_one: UpgradePreview
var preview_two : UpgradePreview

var possible_upgrades: Array[UpgradeData] = [
	preload("res://ui/upgrade/upgrade_data/datas/upgrade_agile.tres"),
	preload("res://ui/upgrade/upgrade_data/datas/upgrade_divine.tres"),
	preload("res://ui/upgrade/upgrade_data/datas/upgrade_empathetic.tres"),
	preload("res://ui/upgrade/upgrade_data/datas/upgrade_intelligent.tres"),
	preload("res://ui/upgrade/upgrade_data/datas/upgrade_perceptive.tres"),
	preload("res://ui/upgrade/upgrade_data/datas/upgrade_powerful.tres"),
	preload("res://ui/upgrade/upgrade_data/datas/upgrade_practical.tres"),
	preload("res://ui/upgrade/upgrade_data/datas/upgrade_serence.tres"),
	preload("res://ui/upgrade/upgrade_data/datas/upgrade_sturdy.tres"),
	preload("res://ui/upgrade/upgrade_data/datas/upgrade_wise.tres")
]

func _ready() -> void:
	visible = false

func open_upgrade_menu():
	if possible_upgrades.size() == 0:
		chosen.emit(null)
		return
	if possible_upgrades.size() == 1:
		_open_upgrade_menu_for_one()
		return
	var upgrade_one : UpgradeData = get_random_upgrade()
	var upgrade_two : UpgradeData = get_random_upgrade()
	while upgrade_one == upgrade_two:
		upgrade_two = get_random_upgrade()
	
	preview_one = UpgradePreview.create_upgrade_preview(upgrade_one)
	preview_two = UpgradePreview.create_upgrade_preview(upgrade_two)
	
	preview_one.chosen.connect(_on_upgrade_chosen)
	preview_two.chosen.connect(_on_upgrade_chosen)
		
	hbox_container.add_child(preview_one)
	hbox_container.add_child(preview_two)
	
	visible = true

func _open_upgrade_menu_for_one():
	var upgrade_one : UpgradeData = get_random_upgrade()
	preview_one = UpgradePreview.create_upgrade_preview(upgrade_one)
	preview_one.chosen.connect(_on_upgrade_chosen)
	hbox_container.add_child(preview_one)
	visible = true
	

func get_random_upgrade() -> UpgradeData:
	return possible_upgrades.get(randi_range(0, possible_upgrades.size() - 1)) as UpgradeData

func _on_upgrade_chosen(data: UpgradeData):
	visible = false
	
	possible_upgrades.erase(data)
	if preview_one:
		preview_one.queue_free()
	if preview_two:
		preview_two.queue_free()
	
	chosen.emit(data)
