class_name Upgrade
extends Control

@export var texture_rect: TextureRect
@export var tooltip_container : PanelContainer
@export var tooltip_label : Label

var upgrade_data: UpgradeData

static func create_upgrade(data: UpgradeData) -> Upgrade:
	var instance : Upgrade = preload("res://ui/upgrade/upgrade.tscn").instantiate()
	instance.upgrade_data = data
	return instance

func _ready() -> void:
	tooltip_container.visible = false
	texture_rect.texture = upgrade_data.texture
	tooltip_label.text = upgrade_data.title + ": " + upgrade_data.description

func _on_hover_panel_mouse_entered() -> void:
	tooltip_container.visible = true

func _on_hover_panel_mouse_exited() -> void:
	tooltip_container.visible = false
