extends Node

var socket = WebSocketPeer.new()
var is_announced = false

func _ready():
	socket.connect_to_url("ws://127.0.0.1:7000")

func _process(delta):
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		if not is_announced:
			socket.send_text("TYPE_B")
			is_announced = true
			
		while socket.get_available_packet_count():
			var packet_data = socket.get_packet()
			print("Packet: ", packet_data)
			var msg_str = packet_data.get_string_from_utf8()
			print(msg_str)
			var msg_ojb = JSON.parse_string(msg_str)
			print(msg_ojb)
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.
