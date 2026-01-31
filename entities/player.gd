class_name Player extends CharacterBody2D

@onready var hitbox := $Hitbox
@onready var DEFAULT_CONTROLS : Mask = $DefaultControls

@export var player_id : String #need function to set this automatically for multiplayer

var current_mask: Mask

var current_hp: int

func _ready() -> void:
	current_mask = DEFAULT_CONTROLS
	current_hp = current_mask.player_stats.max_hp

func set_current_mask(new_mask : Mask):
	if new_mask == current_mask: return
	var hp_ratio = 1
	if current_mask:
		hp_ratio = current_hp/current_mask.player_stats.max_hp
		remove_child(current_mask)
		owner.add_child(current_mask)
	current_mask = new_mask
	add_child(current_mask)
	
	current_hp = current_mask.player_stats.max_hp * hp_ratio

func _physics_process(delta: float) -> void:
	current_mask.player_controller.movement(self, delta)
	set_aim()
	current_mask.attack(self)
	current_mask.ability(self)
	move_and_slide()

func set_aim():
	if !current_mask: return
	var x_aim = Input.get_axis(player_id+"_left", player_id+"_right")
	var y_aim = Input.get_axis(player_id+"_up", player_id+"_down")
	current_mask.look_at(global_position + Vector2(x_aim, y_aim))
