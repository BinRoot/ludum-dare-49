extends Camera2D


export var horse_path: NodePath
var horse

# Called when the node enters the scene tree for the first time.
func _ready():
	horse = get_node(horse_path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = horse.body.global_position
