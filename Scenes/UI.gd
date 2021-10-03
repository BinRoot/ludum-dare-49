extends Control


onready var progress_bar: ProgressBar = $ProgressBar
onready var try_again_button: Button = $TryAgainButton
onready var victory_sprite: AnimatedSprite = $VictorySprite
onready var arrow_sprite: AnimatedSprite = $ArrowSprite
onready var gates_sprite: AnimatedSprite = $GatesSprite
onready var instruction_label: Label = $InstructionLabel
onready var instruction_tween: Tween = $Tween
var horse

var horse_prev_gear = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	horse = get_parent().horse
	instruction_tween.interpolate_property(instruction_label, "modulate",
		instruction_label.modulate, Color.transparent, 15,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	instruction_tween.interpolate_property(instruction_label, "rect_position",
		instruction_label.rect_position, instruction_label.rect_position + Vector2.UP * 75, 5,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	instruction_tween.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not horse:
		horse = get_parent().horse
		return
	progress_bar.value = horse.stamina
	try_again_button.visible = horse.is_hosed or horse.is_entered_pasture
	victory_sprite.visible = horse.is_entered_pasture
	arrow_sprite.visible = horse.current_gear == 0 and (not horse.is_hosed) and (not horse.is_entered_pasture)
	
	if horse_prev_gear == 0 and horse.current_gear == 1:
		gates_sprite.play("stand-to-walk")
	elif horse_prev_gear == 1 and horse.current_gear == 2:
		gates_sprite.play("walk-to-trot")
	elif horse_prev_gear == 2 and horse.current_gear == 3:
		gates_sprite.play("trot-to-canter")
	elif horse_prev_gear == 3 and horse.current_gear == 4:
		gates_sprite.play("canter-to-gallop")
	elif horse_prev_gear == 4 and horse.current_gear == 3:
		gates_sprite.play("gallop-to-canter")
	elif horse_prev_gear == 3 and horse.current_gear == 2:
		gates_sprite.play("canter-to-trot")
	elif horse_prev_gear == 2 and horse.current_gear == 1:
		gates_sprite.play("trot-to-walk")
	elif horse_prev_gear == 1 and horse.current_gear == 0:
		gates_sprite.play("walk-to-stand")
	elif horse_prev_gear > 1 and horse.current_gear == 1:
		gates_sprite.play("walk")
		
	horse_prev_gear = horse.current_gear

func _on_Button_pressed():
	get_tree().reload_current_scene()
