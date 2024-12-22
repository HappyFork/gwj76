extends Node3D


const MENU = preload( "res://scenes/main_menu.tscn" )
const WIN_MUSIC = preload("res://assets/Sound/Music/GWJ 2.1_GoodGame!.mp3")
@onready var ens = $Enemies


func _ready():
	for c in ens.get_children():
		c.froze.connect( _on_enemy_froze )

func end_game():
	get_tree().paused = true
	Input.mouse_mode == Input.MOUSE_MODE_VISIBLE
	$CanvasLayer/ColorRect.visible = true
	$MusicPlayer.stream = WIN_MUSIC
	$MusicPlayer.play()


func _on_menu_button_pressed():
	get_tree().change_scene_to_packed( MENU )

func _on_quit_button_pressed():
	get_tree().quit()

func _on_enemy_froze():
	var t = true
	for c in ens.get_children():
		if c.isnt_frozen():
			t = false
	if t:
		end_game()
