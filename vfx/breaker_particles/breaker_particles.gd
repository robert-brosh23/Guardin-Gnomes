class_name BreakerParticles
extends Node2D

@export var particles: GPUParticles2D

const SCENE := preload("res://vfx/breaker_particles/breaker_particles.tscn")

static var color_dict: Dictionary = {
	"rock" : preload("res://vfx/breaker_particles/color_ramps/rock.tres"),
	"pixie" : preload("res://vfx/breaker_particles/color_ramps/pixie.tres"),
	"thorn_bush" : preload("res://vfx/breaker_particles/color_ramps/thorn.tres")
}

static func create_breaker_particles(color: String = "rock") -> BreakerParticles:
	var gradient := color_dict.get(color) as GradientTexture1D
	var breaker_particles := SCENE.instantiate() as BreakerParticles
	breaker_particles.particles.process_material.set("color_ramp", gradient)
	breaker_particles.particles.emitting = true
	return breaker_particles

func _ready():
	await get_tree().create_timer(1.0).timeout
	queue_free()
