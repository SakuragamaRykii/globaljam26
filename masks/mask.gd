class_name Mask extends Node2D

#attacks are managed here

@export var player_stats: PlayerStatsResource
@onready var attack_cd: Timer = $AttackCD
@onready var pivot: Node2D = $Pivot
@onready var sprite : Sprite2D = $Sprite2D
@export var mask_type: String


var player_controller: ControllerComponent
var can_attack: bool = true
var aura_colour: String
var ability_used: bool = false

func attack(source_player: Player): pass
func ability(source_player: Player): pass

func set_attack_state(state: bool): #if attacked, start cooldown timer. 
	can_attack = state
	if can_attack: attack_cd.stop()
	else: attack_cd.start()
	
		
func attack_anim(source_player: Player):
	source_player.anim["parameters/playback"].travel("AttackBlend")
	source_player.anim["parameters/AttackBlend/blend_position"] = Vector2(1, 0).rotated(pivot.rotation)

func flip_sprite(source_player: Player):
	if source_player.velocity.x != 0:
		sprite.flip_h = source_player.velocity.x > 0
	
