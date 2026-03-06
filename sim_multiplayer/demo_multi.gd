extends Node2D

const DROP_SPAWN_Y_POS = 500

@export var arena_start_pos: Vector2
@export var arena_end_pos : Vector2

@export var drops_available: Array[PackedScene]

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var pause_menu: Control = $SceneUI/PauseMenu
@onready var drop_spawn_cooldown: Timer = $DropSpawnCD

## -------------Multiplayer stuff---------------

@export var player_scene: PackedScene
@export var app_id : int = 480

var lobby_id : int
var peer : SteamMultiplayerPeer
var is_host : bool = false
var is_joining : bool = false
var players_in_lobby : Array[Player] = []

## --------------Other metadata-------------------

var drop_spawn_index : int = 0
var drop_spawn_times : Array[float] = [5., 3., 12]

var alive_players : Array[Player] = []

var round_finished : bool = true

var paused: bool = false
signal unpause

const ROUND_FINISH_TEXT : Array[String] = ["UNMATCHED", "THIRST FOR BLOOD", "MASSACRE"]

func check_mask_colour(mask) -> String:
	var result = ""
	match typeof(mask):
		"MageMask":
			result = "5951C9"
		"StarMask":
			result = "FAD634"
		"TankMask":
			result = "0A8059"
	return result

func _ready() -> void:
	$BGM.play()
	print("Steam Initialized: ", Steam.steamInit(app_id, true))
	Steam.initRelayNetworkAccess()
	Steam.lobby_created.connect(on_lobby_created)
	Steam.lobby_joined.connect(on_lobby_joined)
	
	#var names_size = GameManager.player_names.size()
	await Steam.lobby_created
	anim.play("round_countdown")
	#chinese mistake
	await anim.animation_finished
	
	if paused: await unpause
	round_finished = false
	for player in alive_players:
		player.respawn()
	drop_spawn_cooldown.start()
		
# i wonder how many yap comments im gonna have left on this project by the time im done


@rpc("any_peer", "call_local", "reliable")
func eliminate(player: Player):
	if round_finished: return
	print("called eliminate")
	alive_players.erase(player)	
	check_win()

func check_win():
	print("called check win")
	if alive_players.size() != 1: return
	round_finished = true
	round_finish()
	Engine.time_scale = 0.1
	await get_tree().create_timer(0.2).timeout
	Engine.time_scale = 1.0
	await get_tree().create_timer(0.05).timeout
	
	reset()

func reset():
	for player in players_in_lobby: player.set_physics_process(false)

	anim.play("round_countdown")
	#chinese mistake
	await anim.animation_finished
	if paused: await unpause
	round_finished = false
	for player in alive_players: player.respawn()
	drop_spawn_cooldown.start()
	
func round_finish():
	if !alive_players: return
	var player = alive_players[0]
#	var id_num = int(player.player_id[1]) - 1
#	$SceneUI/RoundFinish/Label.self_modulate = GameManager.PLAYER_COLOUR_CODES[id_num]
	$SceneUI/RoundFinish/Label.text = ROUND_FINISH_TEXT[randi_range(0, ROUND_FINISH_TEXT.size()-1)]
	$SceneUI/RoundFinish.visible = true
	var tw = create_tween()
	tw.tween_property($SceneUI/RoundFinish, "scale", Vector2(1.2, 1.2), 0.2)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		toggle_pause.rpc()

func request_pause():
	pass
	
@rpc("any_peer", "call_local", "reliable")
func toggle_pause():
	pause_menu.visible = !pause_menu.visible
	if pause_menu.visible : pause_game()
	else: resume_game()

func pause_game():
	paused = true
	for pausable in get_children():
		if !pausable.is_in_group("pausable"): continue
		pausable.set_process(false)
		pausable.set_physics_process(false)
		
func resume_game():
	paused = false
	if !round_finished:
		for pausable in get_children():
			if !pausable.is_in_group("pausable"): continue
			pausable.set_process(true)
			pausable.set_physics_process(true)
	unpause.emit()
	

func quit_game():print("quit")


func random_drop():
	var random_x : float = randf_range(arena_start_pos.x, arena_end_pos.x)
	var random_drop_index : int = randi_range(0, drops_available.size()-1)
	
	var instance = drops_available[random_drop_index].instantiate()
	add_child(instance)
	instance.global_position = Vector2(random_x, DROP_SPAWN_Y_POS)
	
	
"""----------------STEAM SHIT------------------"""

func host_lobby():
	if is_host: return
	Steam.createLobby(Steam.LobbyType.LOBBY_TYPE_PUBLIC, 4)
	is_host = true
	
func on_lobby_created(result : int, lid : int):
	if !result == Steam.Result.RESULT_OK: return
	lobby_id = lid
	
	peer = SteamMultiplayerPeer.new()
	peer.server_relay = true
	peer.create_host()
	
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_remove_player)
	_add_player()
	
	print("Lobby created. Lobby ID : ", lobby_id)
	
func join_lobby(id: int):
	is_joining = true
	Steam.joinLobby(id)
	
func on_lobby_joined(lid: int, perms: int, locked : bool, response: int):
	if !is_joining: return
	lobby_id = lid
	peer = SteamMultiplayerPeer.new()
	peer.server_relay = true
	#peer.create_client(Steam.getLobbyOwner(lid))
	var error = peer.connect_to_lobby(lid)
	if  error == OK:
		multiplayer.multiplayer_peer = peer
		print("Connection Successful")
	else:
		print("FAILED TO CONNECT TO LOBBY. ERROR STATE = ", error)
	is_joining = false
	
func _add_player(id : int = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	player.death.connect(eliminate.rpc)
	players_in_lobby.append(player)
	alive_players.append(player)
	call_deferred("add_child", player)

func _remove_player(id : int):
	if !has_node(str(id)): return
	var quitting_player = get_node(str(id))
	players_in_lobby.erase(quitting_player)
	eliminate(quitting_player)
	quitting_player.queue_free()
	


"""----------------------------------"""


func _on_legal_area_body_exited(body: Node2D) -> void:
	if body is Player and !pause_menu.visible:
		print("off map")
		body.get_node("FallSFX").play()
		body.die()

func _on_resume_pressed() -> void:
	toggle_pause().rpc()
	
func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_drop_spawn_cd_timeout() -> void:
	random_drop()
	if drop_spawn_index < 2:
		drop_spawn_index += 1
	drop_spawn_cooldown.start(drop_spawn_times[drop_spawn_index])


func _on_button_pressed() -> void:
	host_lobby()
	
func _on_id_prompt_text_changed(new_text: String) -> void:
	$SceneUI/Join.disabled = new_text.length() == 0

func _on_join_pressed() -> void:
	join_lobby($SceneUI/IDPrompt.text.to_int())
