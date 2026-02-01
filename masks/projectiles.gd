class_name Projectile extends CharacterBody2D

@export var bullet_speed: float
@onready var lifespan : Timer = $Lifespan
@onready var vis : VisibleOnScreenNotifier2D = $VisibleOnScreenEnabler2D

var damage: int
var knockback: float
#above are set externally

func _ready() -> void:
	lifespan.start()
	lifespan.timeout.connect(destroy)
	vis.screen_exited.connect(destroy)

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision:
		var col = collision.get_collider()
		if col is Player: col.handle_damage(damage, knockback * velocity)
			
		destroy()


func destroy():
	queue_free()
