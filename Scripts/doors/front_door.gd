extends Node3D

@onready var anim = $"DoorAnimations"
@onready var is_open = false

func interact():
	print("Interacted with Front Door")
	
	if is_open:
		# Close the door
		anim.play("door_close")
		await anim.animation_finished
		is_open = false
	else:
		# Open the door and transition to neighborhood
		anim.play("door_open")
		await anim.animation_finished
		is_open = true
		await get_tree().create_timer(0.5).timeout
		
		# Transition to neighborhood scene
		transition_to_neighborhood()

func transition_to_neighborhood():
	print("Transitioning to Neighborhood...")
	get_tree().change_scene_to_file("res://Scenes/Neighborhood.tscn")
