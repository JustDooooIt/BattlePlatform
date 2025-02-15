class_name Network extends Enemy

func _ready() -> void:
	polling_battle_comment()
	pass

func polling_battle_comment():
	while true:
		await get_tree().create_timer(2.5).timeout
		if !GameController.is_game_ready:
			continue
		var command = Discussion.enqueue(
			Discussion.query_battle_comments.bind(
				GameController.faction, GameController.discussion_number)
		)
		command.awaiter.callable_completed.connect(recive_data)
		await command.awaiter.callable_completed

func recive_data(result: Array[Dictionary]):
	print(result)
	pass
