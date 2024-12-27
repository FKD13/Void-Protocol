extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var global_cam_pos = $FreeCam/Camera2D.global_position
	$CanvasLayer/ColorRect.get_material().set_shader_parameter("camera_position", global_cam_pos)
