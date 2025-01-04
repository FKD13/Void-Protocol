extends Node2D
var _nickname = "freecam"

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_left"):
		self.move_local_x(-10)
	if Input.is_action_pressed("ui_right"):
		self.move_local_x(10)
	if Input.is_action_pressed("ui_down"):
		self.move_local_y(10)
	if Input.is_action_pressed("ui_up"):
		self.move_local_y(-10)
