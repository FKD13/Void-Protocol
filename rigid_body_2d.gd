@icon("res://icons/ship.png")
class_name Ship extends RigidBody2D

const Bullet = preload("res://bullet.tscn")

var _last_shot: int = 0

var _thrust_right: float = 0
var _thrust_left: float = 0
var _thrust_forward: float = 0
var _gun_turn: float = 0
var _gun_shoot: bool = false

var _nickname: String = ""
var _timestamp_last_cmd: int = Time.get_ticks_msec()

func _ready() -> void:
	position = Vector2(
		randi_range(-1000, 1000),
		randi_range(-1000, 1000)
	)
	$ShipFrame/CentralBody/Thruster.emitting = false
	$ShipFrame/LeftBooster/Thruster.emitting = false
	$ShipFrame/RightBooster/Thruster.emitting = false

func _physics_process(delta: float) -> void:
	# Rotational thrust
	apply_torque(delta * 40000 * (-_thrust_left + _thrust_right))
	# Forward thrust
	apply_central_force(delta * 80000 * (_thrust_forward) * Vector2(cos(rotation), sin(rotation)))
	# Barrel Rotation
	$ShipFrame/Barrel.rotate(delta * 0.2 * _gun_turn)
	# Shoot
	if _gun_shoot:
		_gun_shoot = false
		# Move ship
		apply_central_force(10000*Vector2(cos($ShipFrame/Barrel.rotation+rotation-PI), sin($ShipFrame/Barrel.rotation+rotation-PI)))
		# Spawn and move bullet
		var bullet: Bullet = Bullet.instantiate()
		get_node("/root/root/Server/BulletContainer").add_child(bullet)
		
		bullet.global_position = global_position
		bullet.linear_velocity = linear_velocity
		bullet.launch($ShipFrame/Barrel.rotation+rotation, 10000, self)
	
	if Time.get_ticks_msec() - _timestamp_last_cmd > 5_000:
		modulate = Color.WEB_GRAY
	else:
		modulate = Color.WHITE

func _update_last_command():
	_timestamp_last_cmd = Time.get_ticks_msec()

func thrust_right(percentage: float) -> void:
	_update_last_command()
	if 0 <= percentage and percentage <= 1:
		_thrust_right = percentage
	
	$ShipFrame/LeftBooster/Thruster.emitting = percentage != 0
	$ShipFrame/LeftBooster/Thruster.amount = round(percentage * 128)

func thrust_left(percentage: float) -> void:
	_update_last_command()
	if 0 <= percentage and percentage <= 1:
		_thrust_left = percentage
	
	$ShipFrame/RightBooster/Thruster.emitting = percentage != 0
	$ShipFrame/RightBooster/Thruster.amount = round(percentage * 128)

func thrust_forward(percentage: float) -> void:
	_update_last_command()
	if 0 <= percentage and percentage <= 1:
		_thrust_forward = percentage
	
	$ShipFrame/CentralBody/Thruster.emitting = percentage != 0
	$ShipFrame/CentralBody/Thruster.amount = round(percentage * 128)

func gun_turn(percentage: float) -> void:
	_update_last_command()
	if -1 <= percentage and percentage <= 1:
		_gun_turn = percentage

func gun_shoot() -> void:
	_update_last_command()
	var now = Time.get_ticks_msec()
	if now - _last_shot > 1000:
		_last_shot = now
		_gun_shoot = true

func destroy() -> void:
	var free_cam = get_node("/root/root/FreeCam")
	free_cam.position = position
	free_cam.get_node("Camera2D").enabled = true
	queue_free()
