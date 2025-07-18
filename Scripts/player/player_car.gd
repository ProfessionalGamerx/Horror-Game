extends Node3D

func interact():
	print("Interacted with ", self.name)
	if Global.interactedWithLittleMan == true:
		get_tree().change_scene_to_file("res://Scenes/leprechaun_house.tscn")
