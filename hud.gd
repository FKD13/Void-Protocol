extends CanvasLayer

@onready var shipcontainer = get_node("/root/root/Server/ShipContainer")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var cam = get_viewport().get_camera_2d()
	$Label.text = "Viewing camera of " + str(cam.get_parent()._nickname) + " (" + str(cam.get_parent()) + ")"

func switch_ship(forward: bool):
	var curr_ship = 0
	var active_ship = get_viewport().get_camera_2d().get_parent()
	if active_ship.name == "FreeCam":
		active_ship = null
	var ships = shipcontainer.get_children()
	if not forward:
		ships.reverse()
	for ship in ships:
		if ship == active_ship or not active_ship:
			get_viewport().get_camera_2d().enabled = false
			var new_selection = ships[(curr_ship+1) % len(ships)]
			new_selection.get_node("Camera2D").enabled = true
		curr_ship += 1

func _on_prevship_pressed() -> void:
	switch_ship(false)

func _on_nextship_pressed() -> void:
	switch_ship(true)
