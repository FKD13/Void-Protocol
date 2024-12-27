extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process_input(true)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	if Input.is_key_pressed(KEY_RIGHT):
		apply_torque(10)
	if Input.is_key_pressed(KEY_LEFT):
		apply_torque(-10)
	if Input.is_key_pressed(KEY_SPACE):
		apply_central_force(10*Vector2(cos(rotation-PI/2), sin(rotation-PI/2)))
