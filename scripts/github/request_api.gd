class_name RequestAPI extends Node

var headers: PackedStringArray = [
		'Content-Type: application/json', 
		'Authorization: Bearer <TOKEN>'
	]
var is_github_connected = false

signal connected

func connect_to_github(client: HTTPClient):
	var err = client.connect_to_host('https://api.github.com', 443)
	if err != OK:
		printerr('Failed to connect to the GitHub API.')
	await connect_request(client)
	print('Connected to the GitHub API.')
	emit_signal('connected')
	is_github_connected = true

func connect_request(client: HTTPClient):
	while true:
		var err = client.poll()
		if err != OK:
			printerr('Poll error:', err)
			return
		match client.get_status():
			HTTPClient.STATUS_DISCONNECTED, HTTPClient.STATUS_CANT_RESOLVE, HTTPClient.STATUS_CANT_CONNECT, HTTPClient.STATUS_CONNECTION_ERROR, HTTPClient.STATUS_TLS_HANDSHAKE_ERROR:
				print("连接未成功，状态: ", client.get_status())
			HTTPClient.STATUS_RESOLVING, HTTPClient.STATUS_CONNECTING, HTTPClient.STATUS_REQUESTING:
				continue
			HTTPClient.STATUS_CONNECTED, HTTPClient.STATUS_BODY:
				return
		await get_tree().process_frame

func execute(client: HTTPClient, type: HTTPClient.Method, url: String, headers: PackedStringArray, params: Dictionary) -> PackedByteArray:
	var body = JSON.stringify(params)
	var result = []
	var err = client.request(HTTPClient.METHOD_POST, url, headers, body)
	if err == OK:
		await connect_request(client)
		while client.get_status() == HTTPClient.Status.STATUS_BODY:
			result.append_array(client.read_response_body_chunk())
			client.poll()
			await get_tree().process_frame
	else:
		printerr('The request failed with error code ' + str(err))
	return result
	
