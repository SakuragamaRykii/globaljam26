extends MultiplayerSpawner

@export var network_player: PackedScene	

func _ready() -> void:
	multiplayer.peer_connected.connect(spawn_player)
	
	
func spawn_player(id: int) -> void:
	if !multiplayer.is_server(): return
	if GameManager.players_in_game >= GameManager.player_names.size(): return
	var player: Player = network_player.instantiate()
	
	player.name = str(id)
	player.player_name = GameManager.player_names[GameManager.players_in_game]
	player.avatar_name = GameManager.player_selected_avatars[GameManager.players_in_game]
	print(player.avatar_name)
	GameManager.players_in_game += 1
	
	get_node(spawn_path).add_child(player)
	print(player.get_parent().name)

	
