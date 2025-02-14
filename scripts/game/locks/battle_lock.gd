class_name BattleLock extends ValveLock

func _condition(valve_context: ValveContext):
	return false
	
func _unlock(valve_context: ValveContext, unlock_func: Callable) -> void:
	var context: AttackContext = valve_context as AttackContext
	if context.result == Vector2i(0, 0):
		await context.get_enemy().fellback
		await context.get_myself().advanced
		var defensers: Array[Piece] = BattleController.attack_info.get_defenser(context.target)
		for defenser in defensers:
			defenser.game_state = PlayerPiece.GameState.FALLBACK
		GameController.my_pipeline.state = Player.State.PENDING
		await GameController.my_pipeline.notify
		GameController.my_pipeline.state = Player.State.PLAYING
		var attackers: Array[Piece] = BattleController.attack_info.get_attacker(context.target)
		context.piece.game_state = PlayerPiece.GameState.ADVANCE
	else:
		await context.get_myself().fellback
		await context.get_enemy().advanced
		context.piece.game_state = PlayerPiece.GameState.ADVANCE
		context.get_enemy_pipeline().emit_signal('notify')
