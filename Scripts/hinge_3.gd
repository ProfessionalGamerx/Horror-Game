extends Node3D

@onready var anim = $"DoorAnimations3"
@onready var is_open = false

func interact():
	print("Interacted with", self.name)
	if is_open:
		anim.play("door_close3")
		await anim.animation_finished
		is_open = false
	else:
		anim.play("door_open3")
		await anim.animation_finished
		is_open = true
