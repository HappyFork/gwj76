extends AudioStreamPlayer


var loopmus : AudioStream = preload("res://assets/Sound/Music/GWJ 2.1_GameplayMusicLoop.mp3")


func _on_finished():
	stream = loopmus
	
