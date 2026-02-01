extends Mask

@export var mage_bullet: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_controller = DefaultController.new(player_stats.speed, player_stats.jump_velocity)


func attack(source_player: Player): 
	if can_attack and Input.is_action_just_pressed(source_player.player_id + "_attack"):
		var bullet: Projectile = mage_bullet.instantiate()
		bullet.global_position = $ShootPos.global_position
		bullet.velocity = Vector2(bullet.bullet_speed, 0).rotated(rotation)
		bullet.damage = player_stats.attack_damage
		bullet.knockback = player_stats.knockback_ratio
		get_parent().get_parent().add_child(bullet)
		can_attack = false
		attack_cd.start()
	
func ability(source_player: Player): pass




#gonna cook some noods brb
#CARBS HAVE BEEN LOADED


func _on_attack_cd_timeout() -> void:
	can_attack = true
	attack_cd.stop()
