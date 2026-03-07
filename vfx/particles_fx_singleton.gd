extends Node2D

@export var every_effect: Array[ParticleProcessMaterial]

func _ready():
	load_cache()
	
func load_cache():
	for effect in every_effect:
		var particle_instance : GPUParticles2D = GPUParticles2D.new()
		particle_instance.process_material = effect
		particle_instance.one_shot = true
		particle_instance.emitting = true
		add_child(particle_instance)
