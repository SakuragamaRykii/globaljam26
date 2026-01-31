class_name Mask extends Node2D

#attacks are managed here

@export var player_stats: PlayerStatsResource
@onready var attack_cd: Timer = $AttackCD

var player_controller: ControllerComponent
var can_attack: bool = true


func attack(source_player: Player): pass
func ability(source_player: Player): pass

func set_attack_state(state: bool): #if attacked, start cooldown timer. 
	can_attack = state
	if can_attack: attack_cd.stop()
	else: attack_cd.start()
