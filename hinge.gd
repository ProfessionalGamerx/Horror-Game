extends Node3D

@onready var animation_player: AnimationPlayer = $DoorAnimation
var isdooropen = false

func _process(delta):
	if Input.is_action_just_pressed("interact"):
		if not animation_player.is_playing ():
			animation_player.play("door_open")
			
	elif 
