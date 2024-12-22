extends Node3D


const MENU = preload( "res://scenes/main_menu.tscn" )
const WIN_MUSIC = preload("res://assets/Sound/Music/GWJ 2.1_GoodGame!.mp3")
#var start_time
#var end_time
@onready var ens = $Enemies


func _ready():
	#start_time = Time.get_unix_time_from_system()
	for c in ens.get_children():
		c.froze.connect( _on_enemy_froze )

func end_game():
	get_tree().paused = true
	#end_time = Time.get_unix_time_from_system()
	#var diff = end_time - start_time
	#var mins = floori( int(diff)/60 )
	#var secs = floori( int(diff)%60 )
	#$CanvasLayer/ColorRect/TimeLabel.text += "%02d" % str(mins) + ":" + "%02d" % str(secs)
	Input.mouse_mode == Input.MOUSE_MODE_VISIBLE
	$CanvasLayer/ColorRect.visible = true
	$MusicPlayer.stream = WIN_MUSIC
	$MusicPlayer.play()

func _on_ui_go_home():
	get_tree().change_scene_to_packed( MENU )

func _on_ui_go_gone():
	get_tree().quit()

func _on_enemy_froze():
	var t = true
	for c in ens.get_children():
		if c.isnt_frozen():
			t = false
	if t:
		end_game()
