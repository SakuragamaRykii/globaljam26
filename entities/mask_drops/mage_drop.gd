extends MaskDrop

func _ready() -> void:
	mask = get_parent().get_node("MageMask")
