class_name DefaultController extends ControllerComponent

func movement(target_player: Player, delta: float): 
	print("running")
	if not target_player.is_on_floor():
		target_player.velocity += target_player.get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed(target_player.player_id + "_up") and target_player.is_on_floor():
		target_player.velocity.y = jump_velocity
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_x := Input.get_axis(target_player.player_id + "_left", target_player.player_id + "_right")
	var direction_y := Input.get_axis(target_player.player_id + "_up", target_player.player_id + "_down")

	if direction_x:
		target_player.velocity.x = direction_x * speed
	else:
		target_player.velocity.x = move_toward(target_player.velocity.x, 0, speed)
	
