extends Panel


const MENU = preload( "res://scenes/main_menu.tscn" )
var pl : Player = null


func _ready():
	pl = get_tree().get_root().find_child( "Player" )

func _on_m_sense_slide_value_changed(value):
	pl.TURN_DAMP = ((100.0-value)*3) + 100.0

func _on_default_button_pressed():
	$CenterContainer/VBoxContainer/MouseSensitivity/MSenseSlide.value = 50.0

func _on_menu_button_pressed():
	get_tree().change_scene_to_packed( MENU )

func _on_quit_button_pressed():
	get_tree().quit()
