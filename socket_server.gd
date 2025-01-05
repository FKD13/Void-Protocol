extends Node

var ship = preload("res://ship.tscn")

var socket = WebSocketPeer.new()
var is_announced = false
var game_state_sync_delta_sum_timout_float: float = 0.36
var state_game_sync_timeout_delta_interval_float: float = 0.1 # 10 Hz

@export var URL: String = "ws://localhost:7000"

func _ready():
	socket.connect_to_url(URL)

func _process(delta):
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		if not is_announced:
			socket.send_text("TYPE_B")
			is_announced = true
			
		while socket.get_available_packet_count():
			var packet_data = socket.get_packet()
			var msg_str = packet_data.get_string_from_utf8()
			print(msg_str)
			_handle_message(JSON.parse_string(msg_str))
		
		game_state_sync_delta_sum_timout_float += delta
		if game_state_sync_delta_sum_timout_float > state_game_sync_timeout_delta_interval_float:
			var game_state = {"ships": [], "bullets": []}
		
			for ship: RigidBody2D in get_tree().get_nodes_in_group("ships"):
				game_state["ships"].append({
					"uuid": ship.name,
					"position": [
						_round_to_dec(ship.position.x, 2), 
						_round_to_dec(ship.position.y, 2)
					],
					"rotation": _round_to_dec(ship.rotation, 4),
					"linear_velocity": [
						_round_to_dec(ship.linear_velocity.x, 6), 
						_round_to_dec(ship.linear_velocity.y, 6)
					],
					"angular_velocity": _round_to_dec(ship.angular_velocity, 6),
					"gun_rotation": _round_to_dec(ship.get_node("ShipFrame/Barrel").rotation, 4),
				})
			
			for bullet: RigidBody2D in get_tree().get_nodes_in_group("bullets"):
				game_state["bullets"].append({
					"position": [
						_round_to_dec(bullet.position.x, 2), 
						_round_to_dec(bullet.position.y, 2)
					],
					"linear_velocity": [
						_round_to_dec(bullet.linear_velocity.x, 6), 
						_round_to_dec(bullet.linear_velocity.y, 6)
					],
				})
			
			socket.send_text(JSON.stringify({"type": "game_state", "value": game_state}))
			
			game_state_sync_delta_sum_timout_float = 0
			
	elif state == WebSocketPeer.STATE_CONNECTING:
		pass
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		is_announced = false
		socket.connect_to_url(URL)
		
		# set_process(false) # Stop processing.

func _handle_message(message: Dictionary):
	match message.type:
		"registration":
			_registration(message)
		"turn_right":
			_turn_right(message)
		"turn_left":
			_turn_left(message)
		"thrust_forward":
			_thrust_forward(message)
		"gun_turn":
			_gun_turn(message)
		"gun_shoot":
			_gun_shoot(message)
		var unkown_action:
			print("Got unkown action: %s" % [unkown_action])

func _registration(message: Dictionary):
	var new_ship = ship.instantiate()
	new_ship.name = message.client_id
	new_ship._nickname = message.value
	
	# Add a camera so we can follow the ship
	#var root = get_tree().root
	#var freecam = get_node("/root/FreeCam/Camera2D")
	#freecam.enabled = false
	for cam in get_tree().get_nodes_in_group("camera"):
		cam.enabled = false
	new_ship.get_node("Camera2D").enabled = true
	
	$ShipContainer.add_child(new_ship)

func _turn_right(message: Dictionary):
	var current_ship = $ShipContainer.get_node(message.client_id)
	if current_ship != null:
		current_ship.thrust_right(message.value)

func _turn_left(message: Dictionary):
	var current_ship = $ShipContainer.get_node(message.client_id)
	if current_ship != null:
		current_ship.thrust_left(message.value)

func _thrust_forward(message: Dictionary):
	var current_ship = $ShipContainer.get_node(message.client_id)
	if current_ship != null:
		current_ship.thrust_forward(message.value)

func _gun_turn(message: Dictionary):
	var current_ship = $ShipContainer.get_node(message.client_id)
	if current_ship != null:
		current_ship.gun_turn(message.value)

func _gun_shoot(message: Dictionary):
	var current_ship = $ShipContainer.get_node(message.client_id)
	if current_ship != null:
		current_ship.gun_shoot()

func _round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
