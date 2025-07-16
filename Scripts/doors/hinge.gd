extends Node3D

@onready var anim = $"DoorAnimations"
@onready var is_open = false

func interact():
	print("Interacted with", self.name)
	if is_open:
		anim.play("door_close")
		await anim.animation_finished
		is_open = false
	else:
		anim.play("door_open")
		await anim.animation_finished
		is_open = true
