extends CharacterBody2D

func _ready() -> void:
	$DamageCD.start()



func _on_damage_cd_timeout() -> void:
	for entity in $DamageTest.get_overlapping_bodies():
		if entity is Player:
			entity.handle_damage(10)
	
