extends Control


func _on_client_pressed() -> void:
	HighLevelNetworkHandler.create_client()


func _on_server_pressed() -> void:
	HighLevelNetworkHandler.create_server()
