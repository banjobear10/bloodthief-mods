extends ModNode

# TAS Mod for Bloodthief
class_name BloodthiefTASMod

var is_recording: bool = false
var is_playing_back: bool = false
var input_log: Array = []
var playback_index: int = 0
var playback_timer: Timer

func init():
	ModLoader.mod_log(name_pretty + " TAS Mod loaded!")
	# Set up input recording and playback actions
	add_input_event("tas_toggle_record", [KEY_O])
	add_input_event("tas_toggle_playback", [KEY_P])
	
	# Initialize playback timer
	playback_timer = Timer.new()
	playback_timer.one_shot = false
	playback_timer.wait_time = 1.0 / 60.0  # 60 FPS
	playback_timer.timeout.connect(_on_playback_tick)
	add_child(playback_timer)

func _process(delta):
	if Input.is_action_just_pressed("tas_toggle_record"):
		toggle_recording()
	if Input.is_action_just_pressed("tas_toggle_playback"):
		toggle_playback()
	
	if is_recording and GameManager.get_player():
		record_input()

func toggle_recording():
	is_recording = !is_recording
	if is_recording:
		input_log.clear()
		ModLoader.mod_log("Recording started.")
	else:
		ModLoader.mod_log("Recording stopped.")

func toggle_playback():
	if is_recording:
		ModLoader.mod_log("Stop recording before playback.")
		return
	is_playing_back = !is_playing_back
	if is_playing_back:
		playback_index = 0
		playback_timer.start()
		ModLoader.mod_log("Playback started.")
	else:
		playback_timer.stop()
		ModLoader.mod_log("Playback stopped.")

func record_input():
	var current_input = {
		"position": GameManager.get_player().global_position,
		"velocity": GameManager.get_player().velocity,
		"actions": get_pressed_actions()
	}
	input_log.append(current_input)

func get_pressed_actions() -> Array:
	var actions = []
	for action in InputMap.get_actions():
		if Input.is_action_pressed(action):
			actions.append(action)
	return actions

func _on_playback_tick():
	if playback_index >= input_log.size():
		toggle_playback()
		return
	
	var frame_data = input_log[playback_index]
	apply_input(frame_data)
	playback_index += 1

func apply_input(frame_data):
	var player = GameManager.get_player()
	if player:
		player.global_position = frame_data["position"]
		player.velocity = frame_data["velocity"]
		for action in frame_data["actions"]:
			Input.action_press(action)
