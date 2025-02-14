class_name Network extends Enemy

func _ready() -> void:
	await Discussion.connected
	pass

func polling_battle_comment():
	while true:
		var command = Discussion.enqueue(Discussion.query_pending_comments.bind(GameController.discussion_number))
		command.awaiter.callable_completed.connect(recive_data)
		await command.awaiter.callable_completed
		await get_tree().create_timer(2.5).timeout

func recive_data(result: Array[Dictionary]):
	print(result)
	pass
