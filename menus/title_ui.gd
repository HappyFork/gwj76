extends CanvasLayer


const controls = preload("res://menus/menu_controls.tscn")
const audio = preload("res://menus/menu_audio.tscn")
const game = preload("res://scenes/forest_map.tscn")
@onready var pause_panel = $ColorRect
@onready var tab_container = $ColorRect/TabContainer


func _ready():
	tab_container.add_child( controls.instantiate() )
	tab_container.add_child( audio.instantiate() )


func _on_start_button_pressed():
	get_tree().change_scene_to_packed( game )

func _on_options_button_pressed():
	pause_panel.visible = !pause_panel.visible

func _on_close_options_button_pressed():
	pause_panel.visible = false
