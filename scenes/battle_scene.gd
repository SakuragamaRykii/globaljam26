extends Node2D

@export var arena_start_pos: Vector2
@export var arena_end_pos : Vector2

@onready var anim : AnimationPlayer = $AnimationPlayer

var alive_players : Array[Player] = []

var round_finished : bool = false

func _ready() -> void:
	var player_scene = load("res://entities/player_base.tscn")
	var names_size = GameManager.player_names.size()
	
	for i in range(names_size):
		var player = player_scene.instantiate()
		add_child(player)
		player.global_position = arena_start_pos + \
		(Vector2((arena_end_pos.x-arena_start_pos.x) * (i/float(names_size)), 0))
		player.death.connect(eliminate)
		player.player_id = "p"+str(i+1)
		alive_players.append(player)
		player.process_mode = Node.PROCESS_MODE_DISABLED
		print(player.global_position)
		print(player.player_id)
	anim.play("round_countdown")
	#chinese mistake
	await anim.animation_finished
	for player in alive_players:
		player.respawn()
		
# i wonder how many yap comments im gonna have left on this project by the time im done
	
func reset():
	print("next round")
	alive_players = []
	var names_size = GameManager.player_names.size()
	var i = 0
	for child in get_children():
		if !child is Player: continue
		names_size = float(names_size)
		alive_players.append(child)
		child.global_position = arena_start_pos + \
		(Vector2((arena_end_pos.x-arena_start_pos.x) * ((names_size - i)/names_size), 0))
		i += 1
		child.process_mode = Node.PROCESS_MODE_DISABLED
	anim.speed_scale = 1.0
	anim.play("round_countdown")
	await anim.animation_finished
	for player in alive_players:
		player.respawn()
	round_finished = false
	
# add round start countdown
	
func eliminate(player: Player):
	if round_finished: return
	print("called eliminate")
	alive_players.erase(player)	
	check_win()

func check_win():
	print("called check win")
	if alive_players.size() != 1: return
	round_finished = true
	Engine.time_scale = 0.1
	await get_tree().create_timer(0.2).timeout
	Engine.time_scale = 1.0
	await get_tree().create_timer(0.2).timeout
	
	reset()

func _on_legal_area_body_exited(body: Node2D) -> void:
	if body is Player:
		body.die()
