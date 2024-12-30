extends Control


@export var in_game = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !in_game:
		$CenterContainer/ColorRect/TabContainer/General.queue_free()
	else:
		$CenterContainer/ColorRect/CloseButton.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_close_button_pressed() -> void:
	hide()
