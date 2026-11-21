extends Node


enum StartingScene {TITLE_SCREEN,GAME,AXE_CAMPAIGN}

@export var starting_menu:StartingScene = StartingScene.TITLE_SCREEN

var current_scene:Node


func _ready() -> void:
	match starting_menu:
		StartingScene.TITLE_SCREEN:
			launch_scene(load("res://content/menu/title_screen.tscn"))
		StartingScene.GAME:
			launch_scene(load("res://world.tscn"))
		StartingScene.AXE_CAMPAIGN:
			launch_scene(load("res://content/axe_run/axe_run.tscn"))


func _unhandled_input(event: InputEvent) -> void:
	if starting_menu == StartingScene.TITLE_SCREEN and current_scene is Control and event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		launch_scene(load("res://world.tscn"))


func launch_scene(packed_scene:PackedScene):
	if current_scene:
		current_scene.queue_free()
	current_scene = packed_scene.instantiate()
	add_child(current_scene)
