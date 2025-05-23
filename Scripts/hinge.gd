extends Node3D

@onready var door_open_variable: AnimationPlayer = $"Door Open Animation"
@onready var door_close_variable: AnimationPlayer = $"Door Close Animation"
var is_door_open = false

func _process(delta):
	if Input.is_action_just_pressed("interact") and not is_door_open:
		if not door_open_variable.is_playing():
			door_open_variable.play("door_open")
			is_door_open = true
	elif Input.is_action_just_pressed("interact") and is_door_open:
		if not door_close_variable.is_playing():
			door_close_variable.play("door_close")
			is_door_open = false
