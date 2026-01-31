extends Node2D

@export var arena_start_pos: Vector2
@export var arena_end_pos : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player_scene = load("res://entities/player_base.tscn")
	var names_size = GameManager.player_names.size()
	for i in range(names_size):
		var player = player_scene.instantiate()
		add_child(player)
		player.global_position = arena_start_pos + \
		(Vector2((arena_end_pos.x-arena_start_pos.x) * (i/float(names_size)), 0))
		
		player.player_id = "p"+str(i+1)
		print(player.global_position)
		print(player.player_id)
		
# i wonder how many yap comments im gonna have left on this project by the time im done
		


func _on_legal_area_body_exited(body: Node2D) -> void:
	if body is Player:
		body.die()
