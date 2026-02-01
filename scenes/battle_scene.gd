extends Node2D

@export var arena_start_pos: Vector2
@export var arena_end_pos : Vector2

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var pause_menu: Control = $SceneUI/PauseMenu

var alive_players : Array[Player] = []

var round_finished : bool = false

var paused: bool = false
signal unpause

const ROUND_FINISH_TEXT : Array[String] = ["SPLENDID", "SENSATIONAL", "THIRST FOR BLOOD", "MASSACRE"]

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
	if paused: await unpause
		
	for player in alive_players:
		player.respawn()
		
# i wonder how many yap comments im gonna have left on this project by the time im done
	
func reset():
	print("next round")
	$SceneUI/RoundFinish.visible = false
	$SceneUI/RoundFinish.scale = Vector2.ONE
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
		child.player_id = "p"+str(i)
		child.process_mode = Node.PROCESS_MODE_DISABLED
		
	if paused: await unpause
	anim.speed_scale = 1.0
	anim.play("round_countdown")
	await anim.animation_finished
	if paused: await unpause
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
	round_finish()
	Engine.time_scale = 0.1
	await get_tree().create_timer(0.2).timeout
	Engine.time_scale = 1.0
	await get_tree().create_timer(0.05).timeout
	
	reset()
	
func round_finish():
	if !alive_players: return
	var player = alive_players[0]
	var id_num = int(player.player_id[1]) - 1
	$SceneUI/RoundFinish/Label.self_modulate = GameManager.PLAYER_COLOUR_CODES[id_num]
	$SceneUI/RoundFinish/Label.text = ROUND_FINISH_TEXT[randi_range(0, ROUND_FINISH_TEXT.size()-1)]
	$SceneUI/RoundFinish.visible = true
	var tw = create_tween()
	tw.tween_property($SceneUI/RoundFinish, "scale", Vector2(1.2, 1.2), 0.2)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pause_menu.visible = !pause_menu.visible
		if pause_menu.visible : pause_game()
		else: resume_game()




func pause_game():
	paused = true
	for pausable in get_children():
		if !pausable.is_in_group("pausable"): continue
		pausable.process_mode = Node.PROCESS_MODE_DISABLED
		
func resume_game():
	paused = false
	if !round_finished:
		for pausable in get_children():
			if !pausable.is_in_group("pausable"): continue
			pausable.process_mode = Node.PROCESS_MODE_INHERIT
	unpause.emit()
	

func quit_game():print("quit")

func _on_legal_area_body_exited(body: Node2D) -> void:
	if body is Player and !pause_menu.visible:
		print("off map")
		body.die()



func _on_resume_pressed() -> void:
	pause_menu.visible = false
	resume_game()

func _on_quit_pressed() -> void:
	quit_game()
