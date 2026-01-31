class_name DefaultController extends ControllerComponent

const DECEL : float = 800
const ACCEL : float = 6

func movement(target_player: Player, delta: float): 
	if not target_player.is_on_floor():
		target_player.velocity += target_player.get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed(target_player.player_id + "_up") and target_player.is_on_floor():
		target_player.velocity.y = jump_velocity
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_x := Input.get_axis(target_player.player_id + "_left", target_player.player_id + "_right")
	
	if direction_x:
		target_player.velocity.x += direction_x * speed * delta * ACCEL
		if abs(target_player.velocity.x) >= speed:
			target_player.velocity.x = direction_x * speed
	else:
		if target_player.velocity.x > 0:
			target_player.velocity.x = max(0, target_player.velocity.x - DECEL*delta)
		else:
			target_player.velocity.x = min(0, target_player.velocity.x + DECEL*delta)
	
