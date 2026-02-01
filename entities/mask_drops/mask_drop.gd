class_name MaskDrop extends Area2D

var mask: Mask

@export var mask_backup_scene: PackedScene
@onready var anim : AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_mask()
	anim.play("spawn")
	


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.set_current_mask(mask)
		queue_free()

func init_mask():
	var instance = mask_backup_scene.instantiate()
	mask = instance
	get_tree().root.add_child(mask)
