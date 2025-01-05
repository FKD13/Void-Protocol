@icon("res://icons/bullet.png")
class_name Bullet extends RigidBody2D

static var _id: int = 0
static func id() -> int:
	var id = _id
	_id += 1
	return id

var _origin: Ship

func _ready() -> void:
	name = str(Bullet.id())

func launch(direction: float, force: int, origin: Ship):
	_origin = origin
	apply_central_force(force*Vector2(cos(direction), sin(direction)))

func _on_collision(body):
	if body != _origin:
		$Area2D/CollisionShape2D2.set_deferred("disabled", true)
		$Tail.emitting=false
		$Explosion.emitting=true
		
		if body is Ship:
			body.destroy()
		else:
			body.queue_free()

func _life_ended() -> void:
	queue_free()
