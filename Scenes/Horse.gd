extends Node2D

export var is_player_controlled = true
onready var body: KinematicBody2D = $HorseBody
onready var hosed: AnimatedSprite = $HorseBody/Hosed
onready var dash_animation: AnimatedSprite = $HorseBody/DashSprite
onready var horse_sprite: AnimatedSprite = $HorseBody/HorseSprite
onready var steps_player: AudioStreamPlayer = $StepsPlayer

enum Gear {
	STAND = 0,
	WALK = 1,
	TROT = 2,
	CANTER = 3,
	GALLOP = 4
}

var is_in_motion = false

var is_hosed = false
var is_entered_pasture = false

var current_gear = Gear.STAND
var stamina = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	hosed.visible = is_hosed
	if is_hosed:
		dash_animation.visible = false
		steps_player.stop()
		steps_player.volume_db = 0
		return
	var movement_vec = Vector2.ZERO
	if is_player_controlled:
		if Input.is_action_just_pressed("ui_up"):
			if current_gear < Gear.GALLOP:
				current_gear += 1
		if Input.is_action_just_pressed("ui_down"):
			if current_gear > Gear.STAND:
				current_gear -= 1
		if Input.is_action_pressed("ui_left"):
			body.rotation_degrees -= 1
		if Input.is_action_pressed("ui_right"):
			body.rotation_degrees += 1
	else:
		steps_player.stop()
		steps_player.volume_db = 0
		var player_horse = get_tree().get_nodes_in_group("player")[0]
		var dist_to_player = player_horse.body.global_position.distance_to(body.global_position)
		if dist_to_player < 200:
			body.look_at(player_horse.body.global_position)
			body.rotation_degrees += 90
			if dist_to_player < 150:
				var move_vec = (player_horse.body.global_position - body.global_position).normalized()
				body.move_and_slide(move_vec * 40)
				horse_sprite.speed_scale = 2
				is_in_motion = true
			else:
				is_in_motion = false
				horse_sprite.speed_scale = 0
			
	dash_animation.visible = false
	if is_player_controlled:
		if current_gear == Gear.STAND:
			stamina += 1
			horse_sprite.speed_scale = 0
			steps_player.stream_paused = true
			steps_player.pitch_scale = 1
		elif current_gear == Gear.WALK:
			movement_vec = Vector2.UP * 0.5
			stamina += 0.5
			horse_sprite.speed_scale = 1
			steps_player.stream_paused = false
			steps_player.volume_db = -20
			steps_player.pitch_scale = 1
		elif current_gear == Gear.TROT:
			movement_vec = Vector2.UP * 1
			stamina -= 0.1
			horse_sprite.speed_scale = 2
			steps_player.stream_paused = false
			steps_player.volume_db = -10
			steps_player.pitch_scale = 1.1
		elif current_gear == Gear.CANTER:
			movement_vec = Vector2.UP * 2
			stamina -= 0.2
			horse_sprite.speed_scale = 3
			dash_animation.visible = true
			steps_player.stream_paused = false
			steps_player.volume_db = 1
			steps_player.pitch_scale = 1.5
		elif current_gear == Gear.GALLOP:
			movement_vec = Vector2.UP * 3
			stamina -= 0.6
			dash_animation.visible = true
			horse_sprite.speed_scale = 4
			steps_player.stream_paused = false
			steps_player.volume_db = 10
			steps_player.pitch_scale = 2
		
	stamina = max(0, stamina)
	stamina = min(100, stamina)
	
	if stamina <= 0:
		movement_vec = Vector2.UP
		current_gear = Gear.WALK
	else:
		movement_vec = movement_vec.rotated(body.rotation) * 100
	if current_gear >= Gear.CANTER:
		var col: KinematicCollision2D = body.move_and_collide(movement_vec * delta)
		if col and col.collider is KinematicBody2D and col.collider.name == "CowboyBody":
			col.collider.get_parent().current_state = 1
	else:
		body.move_and_slide(movement_vec)
