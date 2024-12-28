extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process_input(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_RIGHT):
		$Ship.thrust_right(1)
		#$Ship2.thrust_left(1)
	else:
		$Ship.thrust_right(0)
		#$Ship2.thrust_left(0)
	if Input.is_key_pressed(KEY_LEFT):
		$Ship.thrust_left(1)
		#$Ship2.thrust_right(1)
	else:
		$Ship.thrust_left(0)
		#l$Ship2.thrust_right(0)
# 	if Input.is_key_pressed(KEY_SPACE):
# 		thrust_forward()
# 	if Input.is_key_pressed(KEY_K):
# 		gun_right()
# 	if Input.is_key_pressed(KEY_J):
# 		gun_left()
	if Input.is_key_pressed(KEY_L):
		$Ship.gun_shoot()
	if Input.is_key_pressed(KEY_M):
		$Ship2.gun_shoot()
