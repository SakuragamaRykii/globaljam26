extends Mask

const DASH_SPEED = 600

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_controller = DefaultController.new(player_stats.speed, player_stats.jump_velocity)

func attack(source_player : Player): 
	if Input.is_action_just_pressed(source_player.player_id+"_attack") and can_attack:
		print("YOU JUST ATTACKED AFTER 55 HOURS OF PURE CODE LETS GOOO")
		source_player.velocity += Vector2(DASH_SPEED, 0).rotated(rotation)
		set_attack_state(false)
		await attack_cd.timeout
		set_attack_state(true)
		
func ability(source_player : Player): 
	if Input.is_action_just_pressed(source_player.player_id+"_ability"):
		print("Ability is cast??")
