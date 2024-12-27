extends RigidBody2D

var bullet = preload("res://bullet.tscn")

var _last_shot: int = 0

var _thrust_right: float = 0
var _thrust_left: float = 0
var _thrust_forward: float = 0
var _gun_right: float = 0
var _gun_left: float = 0
var _gun_shoot: bool = false

func _physics_process(delta: float) -> void:
	# Rotational thrust
	apply_torque(delta * 40000 * (-_thrust_left + _thrust_right))
	# Forward thrust
	apply_central_force(delta * 80000 * (_thrust_forward) * Vector2(cos(rotation), sin(rotation)))
	# Barrel Rotation
	$Barrel.rotate(delta * 0.1 * (-_gun_left * _gun_right))
	# Shoot
	var now = Time.get_ticks_msec()
	if _gun_shoot and now - _last_shot > 1000:
		_last_shot = now
		_gun_shoot = false
		# Move ship
		apply_central_force(10000*Vector2(cos($Barrel.rotation+rotation-PI), sin($Barrel.rotation+rotation-PI)))
		# Spawn and move bullet
		var b: RigidBody2D = bullet.instantiate()
		get_tree().root.add_child(b)
		b.position = position
		b.rotation = $Barrel.rotation+rotation
		b.launch($Barrel.rotation+rotation, 10000)


func thrust_right(percentage: float) -> void:
	if 0 <= percentage and percentage <= 1:
		_thrust_right = percentage

func thrust_left(percentage: float) -> void:
	if 0 <= percentage and percentage <= 1:
		_thrust_left = percentage

func thrust_forward(percentage: float) -> void:
	if 0 <= percentage and percentage <= 1:
		_thrust_forward = percentage

func gun_right(percentage: float) -> void:
	if 0 <= percentage and percentage <= 1:
		_gun_right = percentage

func gun_left(percentage: float) -> void:
	if 0 <= percentage and percentage <= 1:
		_gun_left = percentage

func gun_shoot_request(shoot: bool) -> void:
	_gun_shoot = shoot
	
