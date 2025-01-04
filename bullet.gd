extends RigidBody2D

var _origin: RigidBody2D
var _has_hit: bool = false
var _lifetime: float = 0

func launch(direction: float, force: int, origin: RigidBody2D):
	_origin = origin
	apply_central_force(force*Vector2(cos(direction), sin(direction)))
		

func _process(delta: float) -> void:
	_lifetime += delta
	
	if (_has_hit and !$Explosion.emitting) or _lifetime > (5 * 60):
		queue_free()

func _on_collision(body):
	if body != _origin:
		$Tail.emitting=false
		$Explosion.emitting=true
		body.queue_free()
		var free_cam = get_node("/root/root/FreeCam")
		free_cam.position = position
		free_cam.get_node("Camera2D").enabled = true
