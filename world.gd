extends Node2D


@export var starting_map:PackedScene
@export var stating_weapon:ResourceWeapon

var map:Map

@onready var rain: GPUParticles2D = %Rain
@onready var rain_on_floor: GPUParticles2D = $CameraGrid/RainOnFloor
@onready var snow: GPUParticles2D = %Snow
@onready var cloud: GPUParticles2D = %Cloud
@onready var leaf: GPUParticles2D = %Leaf
@onready var raylight: GPUParticles2D = %Raylight
@onready var fog: TextureRect = %Fog

@onready var transition: ColorRect = %Transition
@onready var music: AudioStreamPlayer = %Music
@onready var color_correction: ColorRect = %ColorCorrection
@onready var camera_grid: CameraGrid = %CameraGrid
@onready var pivot: Node2D = %Pivot
@onready var player_ui: Control = %PlayerUi


func _ready():
	camera_grid.animation_finished.connect(on_camera_animation_finished)
	generate_map(starting_map)


func on_camera_animation_finished():
	pivot.global_position = camera_grid.global_position


func generate_map(map_scene:PackedScene):
	if not map_scene:
		return
	var next_map := map_scene.instantiate()
	if not next_map is Map:
		next_map.free()
		push_error("The selected scene must use the Map script.")
		return
	if is_instance_valid(map):
		remove_child(map)
		map.queue_free()
	map = next_map
	add_child(map)
	map.environment_area.environment_changed.connect(apply_environment)


func apply_environment(resource_environment:ResourceEnvironment):
	# METEO
	if !resource_environment:
		return
	rain.emitting = ResourceEnvironment.Meteo.RAIN in resource_environment.meteo_list
	rain_on_floor.emitting = rain.emitting
	snow.emitting = ResourceEnvironment.Meteo.SNOW in resource_environment.meteo_list
	cloud.emitting = ResourceEnvironment.Meteo.CLOUD in resource_environment.meteo_list
	leaf.emitting = ResourceEnvironment.Meteo.LEAF in resource_environment.meteo_list
	fog.active = ResourceEnvironment.Meteo.FOG in resource_environment.meteo_list
	raylight.emitting = ResourceEnvironment.Meteo.RAY in resource_environment.meteo_list
	# MUSIC
	if resource_environment.music:
		music.change_music(resource_environment.music)
	else:
		music.stop_music()
	
	# GRADIENT
	color_correction.gradient = resource_environment.color_gradient


func play_transition(type:Transition.Type):
	await transition.play(type)
