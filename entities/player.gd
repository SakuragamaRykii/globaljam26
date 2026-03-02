class_name Player extends CharacterBody2D

var DEFAULT_CONTROLS : Mask 
@onready var hitbox := $Hitbox
@onready var block_zone := $BlockZone
@onready var aura : AnimatedSprite2D = $Aura
@onready var avatar: Sprite2D = $Sprite
@onready var anim: AnimationTree = $AnimationTree

@export var player_id : String #need function to set this automatically for multiplayer
var avatar_name: String
var player_name: String = "PLACEHOLDER"
#HOLY FUCK I FELL ASLEEP
var current_mask: Mask

var current_hp: int
var dead : bool = false
signal death

@onready var root = get_tree().root.get_child(1)

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if (!DEFAULT_CONTROLS): DEFAULT_CONTROLS = $DefaultControls
	set_current_mask(DEFAULT_CONTROLS)
	current_hp = current_mask.player_stats.max_hp
	dead = false
	player_name = GameManager.player_names[GameManager.players_in_game]
	avatar_name = GameManager.player_selected_avatars[GameManager.players_in_game]
	GameManager.players_in_game += 1
	var battle_scene = get_parent()
	death.connect(battle_scene.eliminate)
	battle_scene.alive_players.append(self)
	$PlayerName.text = player_name

func set_current_mask(new_mask : Mask):
	if new_mask == current_mask: return
	if current_mask and new_mask.mask_type == current_mask.mask_type: return

	var hp_ratio = 1
	if current_mask:
		hp_ratio = float(current_hp)/float(current_mask.player_stats.max_hp)
		remove_child(current_mask)
		root.call_deferred("add_child", current_mask)
	current_mask = new_mask
	
	current_mask.reparent(self)
	current_mask.position = Vector2.ZERO
	current_hp = current_mask.player_stats.max_hp * hp_ratio
	
	aura.visible = current_mask != DEFAULT_CONTROLS
	if aura.visible:
		aura.self_modulate = current_mask.aura_colour
		
	print("new hp : ", current_hp)

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority(): return
	if !dead:
		current_mask.player_controller.movement(self, delta)
		set_aim()
		current_mask.attack.rpc(self)
		current_mask.ability.rpc(self)
		current_mask.flip_sprite(self)
		if velocity.x != 0: $Sprite.flip_h = velocity.x > 0
	else: 
		if is_on_floor(): #out of map death can be dealt with another object
			die()
		else:
			velocity += get_gravity() * delta
	manage_movement_anims()
	move_and_slide()
	
func manage_movement_anims():
	if velocity.x and !velocity.y:
		anim["parameters/playback"].travel("move")
	else:
		anim["parameters/playback"].travel("idle")
	if abs(velocity.y) > 0.005:
		anim["parameters/playback"].travel("jump")
		
	
func _process(delta: float) -> void:
	$BlockBar.value = block_zone.blocking_stamina_count + block_zone.block_charge
	$BlockZone/CollisionShape2D.disabled = !Input.is_action_pressed("p1_block")

func set_aim():
	if !current_mask: return
	var x_aim = Input.get_axis("p1_left", "p1_right")
	var y_aim = Input.get_axis("p1_up", "p1_down")
	current_mask.pivot.look_at(global_position + Vector2(x_aim, y_aim))
	block_zone.look_at(global_position + Vector2(x_aim, y_aim))
	
@rpc("any_peer", "call_local", "reliable")
func handle_damage(amount : int, knockback: Vector2):
	if !is_multiplayer_authority(): return
	
	if Input.is_action_pressed("p1_block"):
		var blocking = block_zone.is_blocking_melee()
		if !blocking: 
			take_damage(amount, knockback)
			print("FAILED BLOCK")
		else: print("ATTACK BLOCKED")
	else: 
		take_damage(amount, knockback)
		print("ATTACK NOT BLOCKED")
	if current_hp <= 0:
		$DeathSFX.play()
		dead = true
	#sfx for a successful block should play here
func take_damage(amount : int, knockback: Vector2):
	velocity += knockback
	current_hp -= amount
	print("current hp is ", current_hp)
	$TakeDamageSFX.pitch_scale = randf_range(0.8, 1.2)
	$TakeDamageSFX.play()

func die():
	print(player_id, " has died")
	anim["parameters/playback"].travel("death")
	death.emit(self)
	

func respawn():
	set_process(true)
	set_physics_process(true)
	velocity = Vector2.ZERO
	block_zone.reset()
	set_current_mask(DEFAULT_CONTROLS)
	current_hp = current_mask.player_stats.max_hp
	dead = false


''' ANIM FUNCTIONS'''
const PLAYER_AVATAR_PATH : String = "entities/sprite_sheets/player_avatars/"
func get_attack_down_sprite():
	var texture = load(PLAYER_AVATAR_PATH+avatar_name+"/attack_down.png")
	avatar.texture = texture
func get_attack_side_sprite() :
	var texture = load(PLAYER_AVATAR_PATH+avatar_name+"/attack_side.png")
	avatar.texture = texture
func get_attack_up_sprite() :
	var texture = load(PLAYER_AVATAR_PATH+avatar_name+"/attack_up.png")
	avatar.texture = texture
func get_jump_sprite() :
	var texture = load(PLAYER_AVATAR_PATH+avatar_name+"/jump.png")
	avatar.texture = texture
func get_death_sprite() :
	var texture = load(PLAYER_AVATAR_PATH+avatar_name+"/death.png")
	avatar.texture = texture
func get_move_sprite() :
	var texture = load(PLAYER_AVATAR_PATH+avatar_name+"/move.png")
	avatar.texture = texture
func get_idle_sprite():
	var texture = load(PLAYER_AVATAR_PATH+avatar_name+"/idle.png")
	avatar.texture = texture
