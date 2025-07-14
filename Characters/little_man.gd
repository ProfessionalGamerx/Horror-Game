extends Node3D

@export var dialogue: DialogueResource;
@onready var player = $"../Player"

func interact():
	print("Interacted with", self.name)
	DialogueManager.show_dialogue_balloon(dialogue)
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	#if not dialogue:
		#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
