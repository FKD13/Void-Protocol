extends Node2D



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var cam = get_viewport().get_camera_2d()
	var global_cam_pos = cam.global_position
	$CanvasLayer/ColorRect.get_material().set_shader_parameter("camera_position", global_cam_pos)
