extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


var can_attack : bool = true

@onready var attack_hitbox: Area2D = $AttackHitbox

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("p1_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("p1_attack"):
		attack()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_x := Input.get_axis("p1_left", "p1_right")
	var direction_y := Input.get_axis("p1_up", "p1_down")
	
	if direction_x:
		velocity.x = direction_x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
		
	move_attack_area(Vector2(direction_x, direction_y))
	
	move_and_slide()
	
func move_attack_area(axis : Vector2):
	attack_hitbox.look_at(global_position + axis)
	

	
func attack():
	if !can_attack: return
	print("attacking at angle: ", attack_hitbox.rotation)
	
