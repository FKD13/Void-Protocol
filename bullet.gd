extends RigidBody2D

var _origin: RigidBody2D

func launch(direction: float, force: int, origin: RigidBody2D):
	_origin = origin
	apply_central_force(force*Vector2(cos(direction), sin(direction)))
		
func _on_collision(body):
	if body != _origin:
		body.get_node("Explosion").emitting=true
		#body.queue_free()
