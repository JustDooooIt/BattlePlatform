class_name ValveQueue extends Node2D

var first: Valve = null
var last: Valve = null
var current:Valve = null
var state = IDLE

func _init() -> void:
	name = 'Queue'

func run():
	state = RUNNING
	last.state_changed.connect(
		func(state: int):
			if state == Valve.FINISH:
				self.state = IDLE
	)
	first_run()

func add_valve(valve: Valve) -> void:
	if current != null:
		current.next = valve
	else:
		first = valve
		current = first
	current = valve
	last = valve
	add_child(valve)
	current.state_changed.connect(
		func(state: int):
			if state == Valve.RUNNING:
				current = current.next
			elif state == Valve.WAITING:
				self.state = WAITING
	)
	
func first_run():
	if current != null:
		current.run()

enum {
	IDLE,
	RUNNING,
	WAITING,
	FINISH,
}
