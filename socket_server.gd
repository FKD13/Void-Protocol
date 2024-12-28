extends Node

var ship = preload("res://ship.tscn")

var socket = WebSocketPeer.new()
var is_announced = false

@export var URL: String = "ws://192.168.0.139:7000"

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
		"gun_turn_right":
			_gun_turn_right(message)
		"gun_turn_left":
			_gun_turn_left(message)
		"gun_shoot":
			_gun_shoot(message)
		var unkown_action:
			print("Got unkown action: %s" % [unkown_action])

func _registration(message: Dictionary):
	var new_ship = ship.instantiate()
	new_ship.name = message.client_id
	
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

func _gun_turn_right(message: Dictionary):
	var current_ship = $ShipContainer.get_node(message.client_id)
	if current_ship != null:
		current_ship.gun_right(message.value)

func _gun_turn_left(message: Dictionary):
	var current_ship = $ShipContainer.get_node(message.client_id)
	if current_ship != null:
		current_ship.gun_left(message.value)

func _gun_shoot(message: Dictionary):
	var current_ship = $ShipContainer.get_node(message.client_id)
	if current_ship != null:
		current_ship.gun_shoot()
