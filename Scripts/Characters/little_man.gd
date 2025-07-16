extends Node3D

@export var dialogue: DialogueResource;

func interact():
	print("Interacted with ", self.name)
	var branches = ["Branch1", "Branch2", "Branch3"]
	var chosen = branches[randi() % branches.size()]
	DialogueManager.show_dialogue_balloon(dialogue, chosen)
	Global.interactedWithLittleMan = true
