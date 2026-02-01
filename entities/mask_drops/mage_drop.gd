extends MaskDrop

func _ready() -> void:
	mask = get_parent().get_node("MageMask")
	if !mask:
		var instance = mask_backup_scene.instantiate()
		mask = instance
		get_tree().root.add_child(mask)
