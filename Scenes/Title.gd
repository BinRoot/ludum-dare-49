extends Node2D


# Declare member variables here. Examples:
onready var pasture: TextureRect = $Pasture
onready var title: AnimatedSprite = $TitleLogo
onready var play_button: Button = $PlayButton
onready var title_player: AudioStreamPlayer = $TitlePlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pasture.rect_position = get_viewport().get_visible_rect().size / 2
	pasture.rect_position -= pasture.rect_size / 2
	
	title.position = get_viewport().get_visible_rect().size / 2
	title.position.y -= 125
	
	play_button.margin_left = get_viewport().get_visible_rect().size.x / 2 - play_button.rect_size.x / 2
	play_button.margin_top = get_viewport().get_visible_rect().size.y / 2 - play_button.rect_size.y / 2
	play_button.margin_top += 100


func _on_PlayButton_pressed():
	get_tree().change_scene("res://Scenes/LevelA.tscn")
