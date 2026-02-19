extends Node2D

const DROP_SPAWN_Y_POS = 500

@export var arena_start_pos: Vector2
@export var arena_end_pos : Vector2

@export var drops_available: Array[PackedScene]

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var pause_menu: Control = $SceneUI/PauseMenu
@onready var drop_spawn_cooldown: Timer = $DropSpawnCD

var drop_spawn_index : int = 0
var drop_spawn_times : Array[float] = [5., 3., 12]

var alive_players : Array[Player] = []

var round_finished : bool = false

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
	var player_scene = load("res://entities/player_base.tscn")
	var names_size = GameManager.player_names.size()
	
	#for i in range(names_size):
		#var player = player_scene.instantiate()
		#player.global_position = arena_start_pos + \
		#(Vector2((arena_end_pos.x-arena_start_pos.x) * (i/float(names_size)), 0))
		#player.death.connect(eliminate)
		#player.player_id = "p"+str(i+1)
		#player.avatar_name = GameManager.player_selected_avatars[i]
		#player.player_name = GameManager.player_names[i]
		#alive_players.append(player)
		#add_child(player)
		#player.set_process(false)
		#player.set_physics_process(false)
		#print(player.global_position)
		#print(player.player_id)
		
	anim.play("round_countdown")
	#chinese mistake
	await anim.animation_finished
	if paused: await unpause
		
	for player in alive_players:
		player.respawn()
	
	drop_spawn_cooldown.start()
		
# i wonder how many yap comments im gonna have left on this project by the time im done
	
func reset():
	print("next round")
	var children = get_children()
	drop_spawn_index = 0
	for drop in children:
		if drop is MaskDrop:
			drop.queue_free()
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
		child.set_process(false)
		child.set_physics_process(false)
		
	if paused: await unpause
	anim.speed_scale = 1.0
	anim.play("round_countdown")
	await anim.animation_finished
	if paused: await unpause
	for player in alive_players:
		player.respawn()
	round_finished = false
	drop_spawn_cooldown.start(drop_spawn_times[0])
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
	#var id_num = int(player.player_id[1]) - 1
	#$SceneUI/RoundFinish/Label.self_modulate = GameManager.PLAYER_COLOUR_CODES[id_num]
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
	


func _on_legal_area_body_exited(body: Node2D) -> void:
	if body is Player and !pause_menu.visible:
		print("off map")
		body.get_node("FallSFX").play()
		body.die()

func _on_resume_pressed() -> void:
	pause_menu.visible = false
	resume_game()
	
	


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_drop_spawn_cd_timeout() -> void:
	random_drop()
	if drop_spawn_index < 2:
		drop_spawn_index += 1
	drop_spawn_cooldown.start(drop_spawn_times[drop_spawn_index])
