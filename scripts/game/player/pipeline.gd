class_name Player extends Pipeline

var state: State = State.PLAYING
var stage: Stage = Stage.MOVE : 
	set = set_stage

func _ready() -> void:
	pass

func set_stage(value: int):
	for piece in get_children():
		(piece as Piece).game_state = value

enum Stage {
	MOVE,
	ATTACK,
	IDLE
}

enum State {
	PLAYING,
	PENDING
}
