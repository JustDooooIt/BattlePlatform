extends Node2D

var attack_info: AttackInfo = AttackInfo.new()
var counter: Dictionary = {}
var contexts: Stack = Stack.new()
var battle: BattleResolution = BattleResolution.new()
var current_player: int = 0

signal battle_finished(result)

func commit(context: AttackContext):
	contexts.add(context.target, context)
	if counter.has(context.target):
		counter[context.target] += 1
	else:
		counter[context.target] = 1
	# 当计数达到攻击相同地区的算子个数时,触发战斗结算
	if counter[context.target] == attack_info.attackers.get_cell_size(context.target):
		var attackers: Array = attack_info.attackers.get_cell_pieces(context.target)
		var defensers: Array = attack_info.defensers.get_cell_pieces(context.target)
		var result = battle.caculate(attackers, defensers)
		emit_signal('battle_finished', result)

func reset_attack_info():
	attack_info = AttackInfo.new()
	contexts = Stack.new()
	counter = {}
