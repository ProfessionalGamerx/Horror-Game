extends Node3D

@onready var light_on = true

func interact():
	print("Interacted with", self.name)
	if light_on:
		$OmniLight3D.visible = false
		light_on = false
	elif not light_on:
		$OmniLight3D.visible = true
		light_on = true
