extends Node2D

func _ready() -> void:
	if multiplayer.is_server():
		print("I am the server")
	else:
		print("I am a client")
	print("My id is: " + str(multiplayer.get_unique_id()))

	
	# Preconfigure game.
	$Server.create_game()
	#$Lobby.join_game()
	
	#$Lobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.
	
# Called only on the server.
func start_game():
	# All peers are ready to receive RPCs in this scene.
	pass
	TCPServer
