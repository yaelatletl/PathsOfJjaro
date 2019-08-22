extends HTTPRequest

# GameJolt Godot plugin by Ackens https://github.com/ackens/-godot-gj-api
# GameJolt API index page https://gamejolt.com/game-api/doc

const BASE_GAMEJOLT_API_URL = 'https://api.gamejolt.com/api/game/v1_2'

export(String) var private_key
export(String) var game_id
export(bool) var verbose=true

signal gamejolt_request_completed(type,message,finished)

var username_cache
var token_cache
var busy = false
var queue=[]
var requestError = null
var responseResult = null
var responseBody = null
var responseHeaders = null
var responseStatus = null
var jsonParseError = null
var gameJoltErrorMessage = null
var lasttype=[]
func init(pk,gi):
	private_key=pk
	game_id=gi
func _ready():
	connect("request_completed", self, '_on_HTTPRequest_request_completed')
	pass
func auto_auth():
	#get username and token form url on gamejolt (only work with html5)
	var url=str(JavaScript.eval("window.location.href"))
	var tmp = url.split('gjapi_username=')
	if tmp.size()>1:
		username_cache=tmp[1].split("&")[0]
		token_cache=tmp[1].split("gjapi_token=")[1]
		_call_gj_api('/users/auth/', {user_token = token_cache, username = username_cache})
	else:
		print("not html5 game on gamejolt")
func auth_user(username, token):
	_call_gj_api('/users/auth/', {user_token = token, username = username})
	username_cache = username
	token_cache = token
	pass
	
func fetch_user(username=null, id=0):
	_call_gj_api('/users/', {username = username, user_id = id})
	pass
	
func fetch_friends():
	_call_gj_api('/friends/',
		{username = username_cache, user_token = token_cache})
	pass
	
func open_session():
	_call_gj_api('/sessions/open/',
		{username = username_cache, user_token = token_cache})
	pass
	
func ping_session():
	_call_gj_api('/sessions/ping/',
		{username = username_cache, user_token = token_cache})
	pass
	
func close_session():
	_call_gj_api('/sessions/close/',
		{username = username_cache, user_token = token_cache})
	pass
	
func check_session():
	_call_gj_api('/sessions/check/',
		{username = username_cache, user_token = token_cache})
	pass
	
func fetch_trophy(achieved=null, trophy_ids=null):
	_call_gj_api('/trophies/',
		{username = username_cache, user_token = token_cache, achieved = achieved, trophy_id = trophy_ids})
	pass
	
func set_trophy_achieved(trophy_id):
	if username_cache!=null:
		_call_gj_api('/trophies/add-achieved/',
			{username = username_cache, user_token = token_cache, trophy_id = trophy_id})
		pass
	
func remove_trophy_achieved(trophy_id):
	_call_gj_api('/trophies/remove-achieved/',
		{username = username_cache, user_token = token_cache, trophy_id = trophy_id})
	pass

func fetch_scores(table_id=null, limit=null, better_than=null, worse_than=null):
	_call_gj_api('/scores/',
		{username = username_cache, user_token = token_cache, limit = limit, table_id = table_id, better_than = better_than, worse_than = worse_than})
	pass

func fetch_guest_scores(guest, limit=null, table_id=null, better_than=null, worse_than=null):
	_call_gj_api('/scores/',
		{guest = guest, limit = limit, table_id = table_id, better_than = better_than, worse_than = worse_than})
	pass
	
func fetch_global_scores(limit=null, table_id=null, better_than=null, worse_than=null):
	_call_gj_api('/scores/',
		{limit = limit, table_id = table_id, better_than = better_than, worse_than = worse_than})
	pass
	
func add_score(score, sort, table_id=null):
	if username_cache!=null:
		_call_gj_api('/scores/add/',
			{score = score, sort = sort, username = username_cache, user_token = token_cache, table_id = table_id})
		pass
	
func add_guest_score(score, sort, guest, table_id=null):
	_call_gj_api('/scores/add/',
		{score = score, sort = sort, guest = guest, table_id = table_id})
	pass
	
func fetch_score_rank(sort, table_id=null):
	_call_gj_api('/scores/get_rank/', {sort = sort, table_id = table_id})
	pass
	
func fetch_tables():
	_call_gj_api('/scores/tables/',{})
	pass
	
func fetch_data(key, global=true):
	if global:
		_call_gj_api('/data-store/', {key = key})
	else:
		_call_gj_api('/data-store/', {key = key, username = username_cache, user_token = token_cache})
	pass
	
func set_data(key, data, global=true):
	if global:
		_call_gj_api('/data-store/set/', {key = key, data = data})
	else:
		_call_gj_api('/data-store/set/', {key = key, data = data, username = username_cache, user_token = token_cache})
	pass
	
func update_data(key, operation, value, global=true):
	if global:
		_call_gj_api('/data-store/update/',
			{key = key, operation = operation, value = value})
	else:
		_call_gj_api('/data-store/update/',
			{key = key, operation = operation, value = value, username = username_cache, user_token = token_cache})
	pass
	
func remove_data(key, global=true):
	if global:
		_call_gj_api('/data-store/remove/', {key = key})
	else:
		_call_gj_api('/data-store/remove/', {key = key, username = username_cache, token = token_cache})
	pass
	
func get_data_keys(pattern=null, global=true):
	if global:
		_call_gj_api('/data-store/get-keys/', {pattern = pattern})
	else:
		_call_gj_api('/data-store/get-keys/',
			{username = username_cache, user_token = token_cache, pattern = pattern})
	pass
	
func fetch_time():
	_call_gj_api('/time/',{})
	pass

func get_username():
	return username_cache
	pass
	
func get_user_token():
	return token_cache
	pass

# returns true if request execution was positive and response is received
func is_ok():
	return (
		(requestError == OK) and
		(responseResult == RESULT_SUCCESS) and
		(responseStatus >= 200) and
		(responseStatus < 300) and
		(jsonParseError == OK) and
		(gameJoltErrorMessage == null)
	)

func print_error():
	print('GameJolt error.'
	 + ' RequestError: ' + str(requestError)
	 + ' ResponseResult: ' + str(responseResult)
	 + ' JsonParseError: ' + str(jsonParseError)
	 + ' GameJoltErrorMessage: ' + str(gameJoltErrorMessage))

func _reset():
	requestError = null
	responseResult = null
	responseHeaders = null
	responseStatus = null
	responseBody = null
	jsonParseError = null
	gameJoltErrorMessage = null

func _call_gj_api(type, parameters):
	if busy:
		requestError = ERR_BUSY
		queue.append([type,parameters])
		return
	busy = true
	_reset()
	var url = _compose_url(type, parameters)
	lasttype.append(type)
	requestError = request(url)
	if requestError != OK:
		print(requestError)
	pass

func _compose_url(urlpath, parameters={}):
	var final_url = BASE_GAMEJOLT_API_URL + urlpath
	final_url += '?game_id=' + str(game_id)

	for key in parameters.keys():
		var parameter = parameters[key]
		if parameter == null:
			continue
		parameter = str(parameter)
		if parameter.empty():
			continue;
		final_url += '&' + key + '=' + parameter.percent_encode()

	var signature = final_url + private_key
	signature = signature.md5_text()
	final_url += '&signature=' + signature
	if verbose:
		_verbose(final_url)
	return final_url
	pass
	
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	busy = false
	var size=queue.size()
	if size!=0:
		_call_gj_api(queue[0][0], queue[0][1])
		queue.pop_front()
	if result != OK:
		emit_signal('gamejolt_request_completed',lasttype,{"success":false},true if size==0 else false)
		return
	responseResult = result
	responseStatus = response_code
	responseHeaders = headers
	responseBody = body.get_string_from_utf8()
	if verbose:
		_verbose(responseBody)
	responseBody = JSON.parse(responseBody)
	jsonParseError = responseBody.error
	if jsonParseError == OK:
		responseBody = responseBody.result['response']
		if responseBody['success'] == 'true':
			gameJoltErrorMessage = null
			responseBody['success']=true
		else:
			gameJoltErrorMessage = responseBody['message']
			responseBody['success']=false
	else:
		responseBody = null
	emit_signal('gamejolt_request_completed',lasttype[0],responseBody,true if size==0 else false)
	lasttype.pop_front()
	pass # replace with function body

func _verbose(message):
	if verbose:
		print('[GAMEJOLT] ' + message)