extends Node3D

@onready var static_body := $box/StaticBody3D
@onready var col := $box/StaticBody3D/CollisionShape3D

var is_held: bool = false
var original_parent: Node = null
var held_by_hand: Node3D = null 

func pickup(hand: Node3D):
	if not is_held:
		is_held = true
		original_parent = self.get_parent()
		held_by_hand = hand  # store the hand

		original_parent.remove_child(self)
		hand.add_child(self)
		self.transform.origin = Vector3.ZERO
		col.disabled = true

	else:
		is_held = false

		self.get_parent().remove_child(self)
		original_parent.add_child(self)

		# use stored hand to put it in front of the player
		self.global_transform.origin = held_by_hand.global_transform.origin + held_by_hand.global_transform.basis.z * -1.5 + held_by_hand.global_transform.basis.x * -.5
		col.disabled = false
		

		held_by_hand = null  # reset
