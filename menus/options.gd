extends ColorRect


func _on_master_slide_value_changed(value):
	AudioServer.set_bus_volume_db( 0, linear_to_db( value ) )

func _on_music_slide_value_changed(value):
	AudioServer.set_bus_volume_db( 1, linear_to_db( value ) )

func _on_sfx_slide_value_changed(value):
	AudioServer.set_bus_volume_db( 2, linear_to_db( value ) )
