class_name MageMask extends Mask

@export var mage_bullet: PackedScene
@onready var shoot_position: Node2D = $Pivot/ShootPos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_controller = DefaultController.new(player_stats.speed, player_stats.jump_velocity)
	aura_colour = "5951C9"

@rpc("any_peer", "call_local", "reliable")
func attack(): 
	if can_attack and Input.is_action_just_pressed("p1_attack"):
		var source_player = get_parent()
		if source_player is not Player: return
		var bullet: Projectile = mage_bullet.instantiate()
		bullet.global_position = shoot_position.global_position
		bullet.velocity = Vector2(bullet.bullet_speed, 0).rotated(pivot.rotation)
		source_player.velocity -= bullet.velocity/2
		bullet.damage = player_stats.attack_damage
		bullet.knockback = player_stats.knockback_ratio
		attack_anim(source_player)
		get_parent().get_parent().add_child(bullet)
		can_attack = false
		attack_cd.start()

@rpc("any_peer", "call_local", "reliable")
func ability(): 
	if Input.is_action_just_pressed("p1_ability") and !ability_used:
		var source_player = get_parent()
		if source_player is not Player: return
	
		$AudioStreamPlayer.play()
		for player in get_parent().get_parent().get_children():
			if !player is Player: continue
			if player == source_player: continue
			player.set_physics_process(false)
		print("za warudo")
		await get_tree().create_timer(1).timeout
		for player in get_parent().get_parent().get_children():
			if !player is Player: continue
			if player == source_player: continue
			player.set_physics_process(true)
		ability_used = true


func _on_attack_cd_timeout() -> void:
	can_attack = true
	attack_cd.stop()
