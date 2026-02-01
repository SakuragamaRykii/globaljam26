extends Projectile


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	destroy()
	


func _on_lifespan_timeout() -> void:
	destroy()
