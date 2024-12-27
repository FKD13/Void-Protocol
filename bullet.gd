extends RigidBody2D

func launch(direction: float, force: int):
	apply_central_force(force*Vector2(cos(direction), sin(direction)))
