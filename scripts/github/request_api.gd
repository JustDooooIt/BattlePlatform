class_name RequestAPI extends Node

var http: HTTPClient = HTTPClient.new()
var headers: PackedStringArray = [
		'Content-Type: application/json', 
		'Authorization: Bearer <Token>'
	]
var is_github_connected = false
var base_url: String = ''

signal connected

func _ready() -> void:
	connect_to_github(self.http, self.base_url)

func connect_to_github(client: HTTPClient, url: String):
	var err = http.connect_to_host(url, 443)
	if err == OK:
		print('Connected to the GitHub API.')
	else:
		printerr('Failed to connect to the GitHub API.')
	await connect_request(client, HTTPClient.Status.STATUS_CONNECTED)
	emit_signal('connected')
	is_github_connected = true
	
func connect_request(client: HTTPClient, await_flag: HTTPClient.Status):
	while true:
		match client.get_status():
			HTTPClient.STATUS_DISCONNECTED, HTTPClient.STATUS_CANT_RESOLVE, HTTPClient.STATUS_CANT_CONNECT, HTTPClient.STATUS_CONNECTION_ERROR, HTTPClient.STATUS_TLS_HANDSHAKE_ERROR:
				print("连接未成功，状态: ", client.get_status())
				return
			HTTPClient.STATUS_RESOLVING, HTTPClient.STATUS_CONNECTING, HTTPClient.STATUS_REQUESTING:
				client.poll()
			HTTPClient.STATUS_CONNECTED, HTTPClient.STATUS_BODY:
				return
		await get_tree().process_frame

func execute(client: HTTPClient, type: HTTPClient.Method, url: String, headers: PackedStringArray, params: Dictionary) -> PackedByteArray:
	var body = JSON.stringify(params)
	var result = []
	var err = client.request(HTTPClient.METHOD_POST, url, headers, body)
	if err == OK:
		await connect_request(client, HTTPClient.Status.STATUS_BODY)
		if client.get_status() != HTTPClient.Status.STATUS_BODY:
			printerr('The request failed with status code ' + str(client.get_status()))
		while client.get_status() == HTTPClient.Status.STATUS_BODY:
			result.append_array(client.read_response_body_chunk())
			client.poll()
			await get_tree().create_timer(0.5).timeout
	else:
			printerr('The request failed with error code ' + str(err))
	return result
	
