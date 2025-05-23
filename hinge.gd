extends Node3D  # Or Area3D if using it for trigger-based interaction

@export var interaction_distance = 3.0
@export var player_path : NodePath  # Set this to the player in the inspector

var is_open = false

func _process(delta):
	if Input.is_action_just_pressed("interact"):  # You will set this to "E"
		var player = get_node(player_path)
		if player and global_position.distance_to(player.global_position) <= interaction_distance:
			toggle_door()

func toggle_door():
	if is_open:
		$AnimationPlayer.play_backwards("open")
	else:
		$AnimationPlayer.play("open")
	is_open = !is_open
