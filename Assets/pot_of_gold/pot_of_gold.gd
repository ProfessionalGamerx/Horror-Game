extends Node3D

func interact():
	Global.interactedWithPotOfGold = true
	get_tree().change_scene_to_file("res://Scenes/Neighborhood.tscn")
