extends RigidBody3D


var bounced = false


func _on_body_entered(body: Node) -> void:
	if body is Enemy:
		body.change_state( body.States.FROZEN )
		queue_free()
	elif bounced:
		queue_free()
	else:
		bounced = true
