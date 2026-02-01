class_name DefaultController extends ControllerComponent

const DECEL : float = 800
const ACCEL : float = 6

func movement(target_player: Player, delta: float): 
	if not target_player.is_on_floor():
		target_player.velocity += target_player.get_gravity() * delta

	var direction_x := Input.get_axis(target_player.player_id + "_left", target_player.player_id + "_right")
	
	if direction_x:
		if abs(target_player.velocity.x) >= speed:
			if target_player.velocity.x > 0:
				target_player.velocity.x = max(direction_x * speed, target_player.velocity.x - DECEL*delta)
			else:
				target_player.velocity.x = min(direction_x * speed, target_player.velocity.x + DECEL*delta)
		else:
			target_player.velocity.x += direction_x * speed * delta * ACCEL
	else:
		if target_player.velocity.x > 0:
			target_player.velocity.x = max(0, target_player.velocity.x - DECEL*delta)
		else:
			target_player.velocity.x = min(0, target_player.velocity.x + DECEL*delta)
	if target_player.velocity.x and !target_player.velocity.y:
		target_player.anim["parameters/playback"].travel("move")
	else:
		target_player.anim["parameters/playback"].travel("idle")
		
	if Input.is_action_just_pressed(target_player.player_id + "_up") and target_player.is_on_floor():
		target_player.velocity.y = jump_velocity
		target_player.anim["parameters/playback"].travel("jump")
#theres so many fucking if statements that i wish my life was an else block
#idk bro imma ask gpt to shorten this
# ok gpt fuck you
#HOW MANY IF STATEMENTS DO I FUCKING NEED
