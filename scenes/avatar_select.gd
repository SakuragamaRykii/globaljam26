extends Control

var characters = [
	{ "id": "blue", "portrait": preload("res://entities/sprites/mage.png") },
	{ "id": "red", "portrait": preload("res://entities/sprites/star.png") },
	{ "id": "green", "portrait": preload("res://entities/sprites/tank.png") }
]

var p1_index := 0
var p2_index := 1

# --- Node refs (MATCH RUNTIME TREE) ---
@onready var p1_left: TextureButton = $Player1/LeftArrow
@onready var p1_right: TextureButton = $Player1/RightArrow
@onready var p2_left: TextureButton = $Player2/LeftArrow
@onready var p2_right: TextureButton = $Player2/RightArrow

@onready var p1_portrait: TextureRect = $Player1/Portrait
@onready var p2_portrait: TextureRect = $Player2/Portrait

@onready var confirm_button: Button = $Button

func _ready() -> void:
	# Connect arrows
	p1_left.pressed.connect(func(): change_p1(-1))
	p1_right.pressed.connect(func(): change_p1(1))

	p2_left.pressed.connect(func(): change_p2(-1))
	p2_right.pressed.connect(func(): change_p2(1))

	# Confirm
	confirm_button.pressed.connect(start_game)

	update_ui()

func change_p1(dir: int) -> void:
	p1_index = wrapi(p1_index + dir, 0, characters.size())
	if p1_index == p2_index:
		p1_index = wrapi(p1_index + dir, 0, characters.size())
	update_ui()

func change_p2(dir: int) -> void:
	p2_index = wrapi(p2_index + dir, 0, characters.size())
	if p2_index == p1_index:
		p2_index = wrapi(p2_index + dir, 0, characters.size())
	update_ui()

func update_ui() -> void:
	p1_portrait.texture = characters[p1_index].portrait
	p2_portrait.texture = characters[p2_index].portrait

func start_game() -> void:
	
	GameManager.player_selected_avatars = [
		characters[p1_index].id,
		characters[p2_index].id
	]
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")
