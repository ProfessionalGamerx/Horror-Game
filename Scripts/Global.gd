extends Node

var interactedWithLittleMan = false

var fade_anim : AnimationPlayer
var player : Node3D
var spawn_point : Node3D

func kill_player():
	if fade_anim:
		fade_anim.play("fade_out_and_respawn")

func respawn_player():
	if player and spawn_point:
		player.global_transform.origin = spawn_point.global_transform.origin
		player.velocity = Vector3.ZERO
