class_name Player extends CharacterBody2D

@onready var hitbox := $Hitbox
@onready var DEFAULT_CONTROLS : Mask = $DefaultControls
@onready var block_zone := $BlockZone

@export var player_id : String #need function to set this automatically for multiplayer

var current_mask: Mask

var current_hp: int
var dead : bool = false
signal death

@onready var root = get_tree().root

func _ready() -> void:
	current_mask = DEFAULT_CONTROLS
	current_hp = current_mask.player_stats.max_hp
	dead = false

func set_current_mask(new_mask : Mask):
	if new_mask == current_mask: return
	var hp_ratio = 1
	if current_mask:
		hp_ratio = current_hp/current_mask.player_stats.max_hp
		remove_child(current_mask)
		root.call_deferred("add_child", current_mask)
	current_mask = new_mask
	
	current_mask.reparent(self)
	current_mask.position = Vector2.ZERO
	current_hp = current_mask.player_stats.max_hp * hp_ratio

func _physics_process(delta: float) -> void:
	if !dead:
		current_mask.player_controller.movement(self, delta)
		set_aim()
		current_mask.attack(self)
		current_mask.ability(self)
		if velocity.x != 0: $Sprite.flip_h = velocity.x > 0
	else: 
		if is_on_floor(): #out of map death can be dealt with another object
			die()
		else:
			velocity += get_gravity() * delta
	move_and_slide()
	
func _process(delta: float) -> void:
	$BlockBar.value = block_zone.blocking_stamina_count + block_zone.block_charge
	$BlockZone/CollisionShape2D.disabled = !Input.is_action_pressed(player_id+"_block")

func set_aim():
	if !current_mask: return
	var x_aim = Input.get_axis(player_id+"_left", player_id+"_right")
	var y_aim = Input.get_axis(player_id+"_up", player_id+"_down")
	current_mask.look_at(global_position + Vector2(x_aim, y_aim))
	block_zone.look_at(global_position + Vector2(x_aim, y_aim))
	
func handle_damage(amount : int, knockback: Vector2):
	if Input.is_action_pressed(player_id+"_block"):
		
		var blocking = block_zone.is_blocking_melee()
		if !blocking: 
			velocity += knockback
			current_hp -= amount
			print("FAILED BLOCK")
		else: print("ATTACK BLOCKED")
	else: 
		velocity += knockback
		current_hp -= amount
		print("ATTACK NOT BLOCKED")
	if current_hp <= 0:
		dead = true
	#sfx for a successful block should play here


func die():
	print(player_id, " has died")
	process_mode = PROCESS_MODE_DISABLED
	death.emit(self)

func respawn():
	process_mode = PROCESS_MODE_INHERIT
	velocity = Vector2.ZERO
	block_zone.reset()
	set_current_mask(DEFAULT_CONTROLS)
	_ready()
