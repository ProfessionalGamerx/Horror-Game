extends Node3D
@onready var anim = $AnimationPlayer
var is_open = false

func interact():
	print("Interacted with", self.name)
	if is_open:
		anim.play("door_close2")
	else:
		anim.play("door_open2")
	is_open = !is_open
