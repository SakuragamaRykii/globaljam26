extends Node


const IP_ADDRESS : String = "localhost"
const PORT : int = 42069
const MAX_CLIENTS: int = 4


func create_client():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer

func create_server():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer	
