extends StaticBody2D

const MAX_BLOCKING_COUNT : int = 3
const BLOCK_CHARGE_SPEED : float = 0.4

var blocking_stamina_count : int = 3

var block_charge : float = 0.

#no blocking check for ranged becaues projectiles will get freed as soon as it touches
# the static object

func is_blocking_melee() -> bool:
	var attacks = $MeleeBlockZone.get_overlapping_bodies()
	if attacks and blocking_stamina_count > 0: 
		blocking_stamina_count -= 1
		return true
	return false

func _process(delta: float) -> void:
	if blocking_stamina_count >= MAX_BLOCKING_COUNT: return
	if block_charge <= 1:
		block_charge += delta * BLOCK_CHARGE_SPEED
	if block_charge >= 1: 
		blocking_stamina_count += 1
		block_charge = 0.
	
		
	
