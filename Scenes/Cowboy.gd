extends Node2D

enum State {
	IDLE = 0,
	FAINTED = 1
	AWARE = 2,
	STRIKE = 3,
	HIT=4
}

onready var cowboy_body: KinematicBody2D = $CowboyBody
onready var cowboy_texture: TextureRect = $CowboyBody/TextureRect
onready var lasso_sprite: AnimatedSprite = $CowboyBody/LassoSprite
onready var lasso_attack_sprite: AnimatedSprite = $CowboyBody/LassoAttackSprite
onready var lasso_close_sprite: AnimatedSprite = $CowboyBody/LassoCloseSprite
onready var cowboy_sprite: AnimatedSprite = $CowboyBody/CowboySprite
onready var wahwah_player: AudioStreamPlayer2D = $CowboyBody/WahwahPlayer

var current_state = State.IDLE
var strike_node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_state == State.FAINTED:
		cowboy_sprite.rotation_degrees = 90
		lasso_sprite.visible = false
		wahwah_player.stream_paused = true
		lasso_attack_sprite.visible = false
		lasso_close_sprite.visible = false
		modulate = Color.red
		cowboy_sprite.play("idle")
	else:
		lasso_sprite.visible = current_state == State.AWARE
		wahwah_player.stream_paused = current_state in [State.FAINTED, State.HIT, State.IDLE]
		lasso_attack_sprite.visible = current_state == State.STRIKE
		lasso_close_sprite.visible = current_state == State.HIT
		cowboy_texture.rect_rotation = 0
		var is_walking = false
		var walking_vec = Vector2.ZERO
		if current_state != State.HIT:
			for ray_cast in cowboy_body.get_children():
				if not (ray_cast is RayCast2D):
					continue
				var col = ray_cast.get_collider()
				if ray_cast.is_colliding() and col.name == 'HorseBody':
					var detected_player = (col.get_parent().is_player_controlled and \
						(col.get_parent().current_gear >= 2 or current_state >= State.AWARE))
					var detected_nonplayer = (not col.get_parent().is_player_controlled) and \
						col.get_parent().is_in_motion
					if detected_player or detected_nonplayer:
						if col.get_parent().is_hosed:
							continue
						walking_vec = ray_cast.get_collision_normal().normalized() * -40						
						cowboy_body.move_and_slide(walking_vec)
						if cowboy_body.global_position.distance_to(col.global_position) < 150:
							current_state = State.STRIKE
							strike_node = col
						else:
							current_state = State.AWARE
		if walking_vec.length() > 0:
			cowboy_sprite.play("walk")
		else:
			cowboy_sprite.play("idle")
		cowboy_sprite.flip_h = walking_vec.x < 0
		if current_state == State.STRIKE:
			var lasso_vec = strike_node.global_position - lasso_attack_sprite.global_position
			lasso_attack_sprite.global_position += delta * (lasso_vec)
		else:
			lasso_attack_sprite.position = Vector2.ZERO


func _on_Area2D_body_entered(body):
	if current_state == State.FAINTED:
		return
	if body.name == 'HorseBody' and body.get_parent().current_gear <= 3:
		current_state = State.HIT
		lasso_close_sprite.global_position = body.global_position
		lasso_close_sprite.frame = 0
		lasso_close_sprite.play()


func _on_LassoCloseSprite_animation_finished():
	if current_state == State.FAINTED:
		return
	current_state = State.AWARE
	if lasso_close_sprite.global_position.distance_to(strike_node.global_position) < 30:
		if strike_node.get_parent().is_player_controlled:
			current_state = State.IDLE
			strike_node.get_parent().is_hosed = true
		else:
			current_state = State.AWARE
			strike_node.get_parent().is_hosed = true
