extends Node3D

@export var dialogue: DialogueResource;
@export var completedDialogue: DialogueResource;
@onready var Player = $"../Player"

func interact():
	if Global.interactedWithPotOfGold == true:
		print("Interacted with ", self.name)
		var branches = ["Branch1", "Branch2", "Branch3"]
		var chosen = branches[randi() % branches.size()]
		DialogueManager.show_dialogue_balloon(completedDialogue, chosen)
	else:
		print("Interacted with ", self.name)
		var branches = ["Branch1", "Branch2", "Branch3"]
		var chosen = branches[randi() % branches.size()]
		DialogueManager.show_dialogue_balloon(dialogue, chosen)
		Global.interactedWithLittleMan = true
		Player.current_objective()
