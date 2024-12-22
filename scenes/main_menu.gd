extends Node3D


var game = preload("res://scenes/forest_map.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$snowball.rotate_x( 0.1 )
	$snowball.rotate_y( -0.02 )


func _on_button_pressed():
	get_tree().change_scene_to_packed( game )

func _on_options_button_pressed():
	$CanvasLayer/Options.visible = !$CanvasLayer/Options.visible

func _on_close_options_button_pressed():
	$CanvasLayer/Options.visible = false
