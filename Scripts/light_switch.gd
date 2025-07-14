extends Node3D

@onready var light_on = true

func interact():
	print("Interacted with", self.name)
	if light_on:
		$"../LivingRoomLights/LightGroup".visible = false
		$"../LivingRoomLights2/LightGroup".visible = false
		$"../LivingRoomLights3/LightGroup".visible = false
		light_on = false
	elif not light_on:
		$"../LivingRoomLights/LightGroup".visible = true
		$"../LivingRoomLights2/LightGroup".visible = true
		$"../LivingRoomLights3/LightGroup".visible = true
		light_on = true
