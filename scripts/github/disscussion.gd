extends RequestAPI

var query_comments_command: String = \
	"query($number: Int!, $last: Int!) {
		repository(owner: \"JustDooooIt\", name: \"BattlePlatform\"){
			discussion(number: $number){
				title,
				body,
				comments(last: $last){
					nodes {
						author {
							login
						}
						body
						createdAt
					}
				}
			}
		}
	}"

var query_pending_comments_command: String = \
	"query($number: Int!, $last: Int!, $before: String) {
		repository(owner: \"JustDooooIt\", name: \"BattlePlatform\"){
			discussion(number: $number){
				title,
				body,
				comments(last: $last, before: $before){
					pageInfo {
						hasPreviousPage,
						startCursor
					}
					nodes {
						author {
							login
						}
						body
						createdAt
					}
				}
			}
		}
	}"

var query_repository_command: String = \
	"query {
		repository(owner: \"JustDooooIt\", name: \"BattlePlatform\"){
			id
		}
	}"

var create_discussion_command: String = \
	"mutation($title: String!) {
		createDiscussion(input: {
			repositoryId: \"R_kgDON1yf4w\",
			title: $title,
			body: \"battle-room\",
			categoryId: \"DIC_kwDON1yf484Cmvg7\"
		}) {
			discussion {
				id,
				number,
				createdAt
			}
		}
	}"

var create_comment_command: String = \
	"mutation($discussionId: ID!, $body: String!) {
		addDiscussionComment(input: {
			discussionId: $discussionId, body: $body
		}) {
			comment {
				id
				body
				createdAt
					author {
					login
				}
			}
		}
	}"
var query_public_key_command: String = \
	"query($number: Int!, $first: Int!, $after: String) {
		repository(owner: \"JustDooooIt\", name: \"BattlePlatform\"){
			discussion(number: $number){
				title,
				body,
				comments(first: $first, after: $after){
					pageInfo {
						hasNextPage,
						endCursor
					}
					nodes {
						author {
							login
						}
						body
						createdAt
					}
				},
			}
		}
	}"

var http: HTTPClient = HTTPClient.new()

var repo = 'BattlePlatform'
var repo_owner = 'JustDooooIt'
var request_queue: Array[Command] = []

func _ready() -> void:
	while true:
		if request_queue.size() > 0:
			var command: Command = request_queue.pop_front()
			var callable: Callable = command.callable
			var data = await callable.call()
			command.awaiter.emit_signal('callable_completed', data)
		await get_tree().create_timer(2.5).timeout

func http_client_connect():
	await connect_to_github(http)

func execute_graphql(params: Dictionary) -> PackedByteArray:
	return await execute(self.http, HTTPClient.Method.METHOD_POST, '/graphql', headers, params)
	
func query_comments(number: int, last: int = 1) -> Dictionary:
	var command: String = query_comments_command
	var variables = { 'number': number, 'last': last }
	var body = { 'query': command, 'variables': variables }
	var result = await execute_graphql(body)
	return JSON.parse_string(result.get_string_from_utf8())

func query_battle_comments(player_faction:int, number: int, count: int = 1) -> Array[Dictionary]:
	await http_client_connect()
	var command: String = query_pending_comments_command
	var variables = { 'number': number, 'last': count }
	var body = { 'query': command, 'variables': variables }
	var has_pre = true;
	var arr: Array[Dictionary] = []
	while has_pre:
		var result = await execute_graphql(body)
		var dict: Dictionary = JSON.parse_string(result.get_string_from_utf8())
		var cursor = dict['data']['repository']['discussion']['comments']['pageInfo']['startCursor']
		has_pre = dict['data']['repository']['discussion']['comments']['pageInfo']['hasPreviousPage']
		body['variables']['before'] = cursor
		arr.append_array(dict['data']['repository']['discussion']['comments']['nodes'])
	http.close()
	return arr.filter(
		func(e): 
			var dict: Dictionary = JSON.parse_string(e['body'])
			return dict['faction'] != player_faction and dict.has('type') and dict['type'] == COMMENT_TYPE_BATTLE
	)

func create_discussion() -> Dictionary:
	await http_client_connect()
	var command: String = create_discussion_command
	var variables = { 'title': 'battle-room-%s' % str(Time.get_unix_time_from_system()) }
	var body = { 'query': command, 'variables': variables }
	var result = (await execute_graphql(body))
	http.close()
	return JSON.parse_string(result.get_string_from_utf8())
	
func query_repository() -> Dictionary:
	await http_client_connect()
	var command: String = query_repository_command
	var body = { 'query': command }
	var result = await execute_graphql(body)
	http.close()
	return JSON.parse_string(result.get_string_from_utf8())

func create_discussion_id() -> String:
	await http_client_connect()
	var str = await create_discussion()
	var dict: Dictionary = JSON.parse_string(str)
	http.close()
	return dict['data']['createDiscussion']['discussion']['id']
	
func create_discussion_number() -> int:
	await http_client_connect()
	var str = await create_discussion()
	var dict: Dictionary = JSON.parse_string(str)
	http.close()
	return dict['data']['createDiscussion']['discussion']['number']
	
func create_comment(discussionId: String, content: String) -> Dictionary:
	await connect_to_github(http)
	var command: String = create_comment_command
	var variables = { 'discussionId': discussionId, 'body': content }
	var body = { 'query': command, 'variables': variables }
	var result = await execute_graphql(body)
	var dict_str = result.get_string_from_utf8()
	var dict = JSON.parse_string(dict_str)
	http.close()
	return dict
	
func query_public_key(faction: int, number: int, await_time: float = 2.5, max_time: float = 30) -> String:
	await connect_to_github(http)
	var command: String = query_public_key_command
	var variables = { 'number': number, 'first': 1 }
	var body = { 'query': command, 'variables': variables }
	var total_time: float = 0
	while true:
		var result = await execute_graphql(body)
		var string = result.get_string_from_utf8()
		var dict: Dictionary = JSON.parse_string(string)
		var cursor = dict['data']['repository']['discussion']['comments']['pageInfo']['endCursor']
		body['variables']['after'] = cursor
		var nodes: Array = dict['data']['repository']['discussion']['comments']['nodes']
		if nodes.size() > 0:
			var json_str:String = nodes[0]['body']
			var json_dict: Dictionary = JSON.parse_string(json_str)
			if json_dict['faction'] != faction and json_dict.has('public_key'):
				var public_key_url = json_dict['public_key']
				var res = await call_once(HTTPClient.Method.METHOD_GET, public_key_url, get_gists_header())
				return res.get_string_from_utf8()
		await get_tree().create_timer(await_time).timeout
		total_time += await_time
		if total_time > max_time:
			break
	http.close()
	return ''

func upload_public_key(faction: int, public_key: String):
	await connect_to_github(http)
	var file_name = str(Time.get_unix_time_from_system())
	var dict: Dictionary = {
		'description': 'upload %s public key' % GameController.github_username,
		'public': false,
		'files': {
			file_name: { 
				'content': Marshalls.utf8_to_base64(public_key),
				'encode': 'base64'
			}
		}
	}
	var headers = get_gists_header()
	var res = await execute(self.http, HTTPClient.Method.METHOD_POST, '/gists', headers, dict)
	var json_str = res.get_string_from_utf8()
	var file: Dictionary = JSON.parse_string(json_str)
	var raw_url = file['files'][file_name]['raw_url']
	var body = { 'type': COMMENT_TYPE_KEY, 'faction': GameController.faction, 'public_key': raw_url }
	await create_comment(GameController.discussion_id, JSON.stringify(body))
	http.close()

func call_once(method: HTTPClient.Method, url: String, headers: PackedStringArray, params: Dictionary = {}) -> PackedByteArray:
	var _http = HTTPClient.new()
	var urls = url.split('/', false, 2)
	var base_url: String = urls[0] + '//' + urls[1]
	var err = _http.connect_to_host(base_url, 443)
	if err == OK:
		print('Connected to the url.')
	else:
		printerr('Failed to connect to the url.')
	await connect_request(_http)
	var res = await execute(_http, HTTPClient.Method.METHOD_GET, '/' + urls[2], headers, params)
	_http.close()
	return res
	
func enqueue(request: Callable) -> Command:
	var command = Command.new(request, Awaiter.new())
	request_queue.append(command)
	return command

func class_to_dict(clazz: Object):
	var dict = {}
	for prop in clazz.get_property_list():
		var name = prop["name"]
		var usage = prop['usage']
		if usage == PROPERTY_USAGE_SCRIPT_VARIABLE:
			dict[name] = clazz.get(name)
	return dict
	
func get_gists_header():
	var headers = self.headers.duplicate()
	headers.remove_at(0)
	headers.append('Accept: application/vnd.github+json')
	headers.append('X-GitHub-Api-Version: 2022-11-28')
	return headers

class BattleComment:
	var username: String = ''
	var faction: int = -1
	var piece_id: int = -1
	var is_pending: bool = true
	var target: Vector2i = Vector2i()

class Command:
	var callable: Callable
	var awaiter: Awaiter
	
	func _init(callable: Callable, awaiter: Awaiter) -> void:
		self.callable = callable
		self.awaiter = awaiter

class Awaiter:
	signal callable_completed(result)

enum {
	COMMENT_TYPE_BATTLE,
	COMMENT_TYPE_KEY
}
