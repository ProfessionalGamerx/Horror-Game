extends Node3D

@onready var anim = $"DoorAnimations4"
@onready var is_open = true

func interact():
	print("Interacted with", self.name)
	if is_open:
		anim.play("door_close4")
		await anim.animation_finished
		is_open = false
	else:
		anim.play("door_open4")
		await anim.animation_finished
		is_open = true
