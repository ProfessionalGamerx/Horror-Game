extends Node3D

@onready var anim = $"DoorAnimations2"
@onready var is_open = false

func interact():
	print("Interacted with", self.name)
	if is_open:
		anim.play("door_close2")
		await get_tree().create_timer(0.5).timeout
		is_open = false
	else:
		anim.play("door_open2")
		await get_tree().create_timer(0.5).timeout
		is_open = true
