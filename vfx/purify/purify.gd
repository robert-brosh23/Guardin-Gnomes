class_name Purify
extends Node2D

const SCENE := preload("res://vfx/purify/purify.tscn")

@export var ring_front: Sprite2D
@export var ring_back: Sprite2D

var purify_tween_front: Tween
var purify_tween_back: Tween

static func create_purify() -> Purify:
	var scene = SCENE.instantiate() as Purify
	scene.play_purify_anim()
	return scene

func play_purify_anim():
	if purify_tween_front:
		purify_tween_front.kill()
	purify_tween_front = create_tween()
	if purify_tween_back:
		purify_tween_back.kill()
	purify_tween_back = create_tween()
	
	var radius := .3
	ring_front.material.set_shader_parameter("circle_distance", radius)
	ring_back.material.set_shader_parameter("circle_distance", radius)
	
	purify_tween_front.tween_property(ring_front.material, "shader_parameter/circle_distance", 1.0, .7).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	purify_tween_back.tween_property(ring_back.material, "shader_parameter/circle_distance", 1.0, .7).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	purify_tween_back.finished.connect(delete)

func delete():
	queue_free()
