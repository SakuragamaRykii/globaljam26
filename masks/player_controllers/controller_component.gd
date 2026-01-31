class_name ControllerComponent extends Node

var speed : float
var jump_velocity : float

func _init(speed : float, jump_velocity: float) -> void:
	self.speed = speed
	self.jump_velocity = jump_velocity

func movement(target_player: Player, delta : float): pass

	
