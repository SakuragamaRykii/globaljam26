extends StaticBody2D

const MAX_BLOCKING_COUNT : int = 3
const BLOCK_CHARGE_SPEED : float = 0.4

var blocking_stamina_count : int = 3

var block_charge : float = 0.

@onready var player: Player = get_parent()

#no blocking check for ranged becaues projectiles will get freed as soon as it touches
# the static object
func reset():
	blocking_stamina_count = MAX_BLOCKING_COUNT
	block_charge = 0.

func is_blocking_melee() -> bool:
	var attacks = $MeleeBlockZone.get_overlapping_bodies()
	if attacks and blocking_stamina_count > 0: 
		blocking_stamina_count -= 1
		$Block.play()
		return true
	return false

func _process(delta: float) -> void:
	$Slice.visible = Input.is_action_pressed("p1_block") and blocking_stamina_count
	if blocking_stamina_count >= MAX_BLOCKING_COUNT: return
	if block_charge <= 1:
		block_charge += delta * BLOCK_CHARGE_SPEED
	if block_charge >= 1: 
		blocking_stamina_count += 1
		block_charge = 0.
	
		
	
