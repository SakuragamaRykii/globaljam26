extends Mask

const DASH_SPEED = 400
@onready var hitbox := $Hitbox
# Called when the node enters the scene tree for the first time.
@onready var attack_duration: Timer = $AttackDuration

var attacking : bool = false
var attacking_source: Player

func _ready() -> void:
	player_controller = DefaultController.new(player_stats.speed, player_stats.jump_velocity)

func attack(source_player : Player): 
	if Input.is_action_just_pressed(source_player.player_id+"_attack") and can_attack:
		attacking = true
		attacking_source = source_player
		source_player.velocity += Vector2(DASH_SPEED, 0).rotated(rotation)
		attack_duration.start()
# add knockback
		set_attack_state(false)
		await attack_cd.timeout
		set_attack_state(true)
		


func check_hits(source_player : Player):
	var hit_targets = hitbox.get_overlapping_bodies()
	for hit in hit_targets:
		if hit is Player and !hit == source_player:
			print("HIT : ", hit.player_id)
			attacking = false
			hit.handle_damage(player_stats.attack_damage, 
			Vector2(DASH_SPEED, 0).rotated(rotation) * player_stats.knockback_ratio + source_player.velocity/4)

#just went to sainsburys to get some SNACKIESSSS

#bourbons are S tier not many can compete

#man i wish i could spend this much time a day on my game


		
func ability(source_player : Player): 
	if Input.is_action_just_pressed(source_player.player_id+"_ability"):
		print("Ability is cast??")

func _physics_process(delta: float) -> void:
	if attacking: check_hits(attacking_source)
		

func _on_attack_duration_timeout() -> void:
	attack_duration.stop()
	attacking = false
