class_name MaskDrop extends Area2D

var mask: Mask

@export var mask_backup_scene: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.set_current_mask(mask)
		queue_free()
