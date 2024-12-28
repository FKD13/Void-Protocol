extends RigidBody2D

var _origin: RigidBody2D

func launch(direction: float, force: int, origin: RigidBody2D):
	_origin = origin
	apply_central_force(force*Vector2(cos(direction), sin(direction)))

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 2
	body_entered.connect(_on_collision)
		
func _on_collision(body):
	if body != _origin:
		body.queue_free()
