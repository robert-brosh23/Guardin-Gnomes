class_name UpgradePreview
extends Control

signal chosen(upgrade_data: UpgradeData)

@export var texture_rect: TextureRect
@export var title_label: Label
@export var description_label: Label
@export var button: Button

var upgrade_data: UpgradeData

static func create_upgrade_preview(data: UpgradeData) -> UpgradePreview:
	var instance : UpgradePreview = preload("res://ui/upgrade/preview/upgrade_preview.tscn").instantiate()
	instance.upgrade_data = data
	return instance

func _ready() -> void:
	texture_rect.texture = upgrade_data.texture
	title_label.text = upgrade_data.title.to_upper()
	description_label.text = upgrade_data.description
	
	pivot_offset = size * Vector2(0.5, 1.0)
	button.button_down.connect(_on_button_down)

func _on_button_down():
	chosen.emit(upgrade_data)
