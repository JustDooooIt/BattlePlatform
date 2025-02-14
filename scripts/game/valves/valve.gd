## 代表一个算子的原子操作
class_name Valve extends Node2D

@onready var map = get_node("/root/Game/HexMap")

var state = IDLE :
	set(value):
		state = value
		emit_signal('state_changed', value)
var next: Valve = null
var lock: ValveLock = null
var waitable: bool = false
var cancel: bool = false
var piece: Piece = null

signal state_changed(state: int)

func _init(piece: Piece, waitable: bool) -> void:
	self.waitable = waitable
	self.piece = piece

func _run(context: ValveContext) -> void:
	pass

func run() -> void:
	var context: ValveContext = _create_context()
	if waitable:
		await piece.pipeline.notify
		if cancel: return
	state = RUNNING
	await _run(context)
	state = FINISH
	if lock == null:
		if next != null:
			await next.run()
	else:
		lock.wait_unlock(context)

func add_lock(lock: ValveLock) -> void:
	self.lock = lock
	lock.unlock_func = run
	
func _create_context() -> ValveContext:
	return null

enum ContextType {
	MOVE
}

enum {
	IDLE,
	RUNNING,
	WAITING,
	FINISH
}
