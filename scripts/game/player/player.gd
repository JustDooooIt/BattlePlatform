class_name Pipeline extends Node2D

var cur_valve_queues: Dictionary = {}
var valve_queues: Array[Dictionary] = []

signal notify
signal advanced
signal fellback
signal valve_finished

func add_valve(valve: Valve):
	var piece = valve.piece
	if cur_valve_queues.has(piece):
		var queue: ValveQueue = cur_valve_queues[piece]
		var wait: bool = cur_valve_queues[piece].state == ValveQueue.WAITING
		if queue.first == null or (queue.first != null and not wait):
			queue.add_valve(valve)
		assert(not wait, "Queue is waiting")
	else:
		var queue: ValveQueue = ValveQueue.new()
		queue.add_valve(valve)
		piece.add_child(queue)
		cur_valve_queues[piece] = queue

func run(piece: Piece = null):
	if piece == null:
		for queue: ValveQueue in cur_valve_queues:
			queue.run()
	else:
		var vqueue: ValveQueue = cur_valve_queues[piece]
		print(vqueue.state)
		if vqueue.state != ValveQueue.RUNNING:
			vqueue.run()

func remove_all_queues():
	valve_queues.append(cur_valve_queues)
	for piece: Piece in cur_valve_queues.keys():
		var queue = piece.get_node('Queue')
		piece.remove_child(queue)
	cur_valve_queues = {}
