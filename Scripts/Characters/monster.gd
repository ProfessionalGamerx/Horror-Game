extends CharacterBody3D

@onready var nav_agent = get_node("NavigationAgent3D")
@onready var player = get_node("/root/TestHorror/Player")
@onready var laugh = $Laugh
@onready var scream = $Scream
@onready var chaseSequence = $Chase
@onready var anim_player = $ScaryLady/AnimationPlayer
var previous_state = STATE_ROAMING

enum {
	STATE_ROAMING,
	STATE_CHASING
}

var speed = 6.0
var roam_timer = 0.0
var roam_target = Vector3.ZERO
var memory_time = 0.0

const MEMORY_DURATION = 3.0


var current_state = STATE_ROAMING


func can_see_player() -> bool:
	if not player:
		return false

	var to_player = player.global_transform.origin - global_transform.origin
	var distance = to_player.length()
	if distance > 50.0:
		return false

	# Field of view
	var forward = -global_transform.basis.z  # Forward direction
	var angle = forward.normalized().dot(to_player.normalized())
	# cos 45 degrees is 0.707 so an angle of 0.7 means the monster can see in a 45 degree radius cone
	# The smaller the number (can go to negatives) the wider the angle
	if angle < -1:
		return false  # Outside field of view

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_transform.origin, player.global_transform.origin)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	if result and result.collider != player:
		return false  # Something is blocking the view

	return true


func _physics_process(delta):
	if current_state != previous_state:
		_on_state_changed(previous_state, current_state)
		previous_state = current_state
		
	match current_state:
		STATE_ROAMING:
			if can_see_player():
				current_state = STATE_CHASING
				memory_time = MEMORY_DURATION
			else:
				roam(delta)

		STATE_CHASING:
			if can_see_player():
				memory_time = MEMORY_DURATION
				chase(delta)
			else:
				memory_time -= delta
				if memory_time > 0:
					chase(delta)
				else:
					current_state = STATE_ROAMING

func _on_state_changed(old_state, new_state):
	if old_state == STATE_ROAMING and new_state == STATE_CHASING:
		scream.play()
		chaseSequence.play()
	elif old_state == STATE_CHASING and new_state == STATE_ROAMING:
		laugh.play()


###########################################################################################
func roam(delta):
	laugh.play()
	roam_timer -= delta
	if roam_timer <= 0:
		var offset = Vector3(
			randf_range(-10, 10),
			0,
			randf_range(-10, 10)
			)
		roam_target = global_transform.origin + offset
		nav_agent.set_target_position(roam_target)
		roam_timer = 3.0

	if nav_agent.is_navigation_finished():
		velocity = Vector3.ZERO
		anim_player.stop()
		return

	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_transform.origin).normalized()
	velocity = direction * speed
	move_and_slide()

	# Play walking animation only if moving
	if velocity.length() > 0.1:
		if anim_player.current_animation != "walking":
			anim_player.play("walking")
	else:
		anim_player.stop()

###########################################################################################

###########################################################################################
func chase(delta):
	scream.play()
	nav_agent.set_target_position(player.global_transform.origin)

	if nav_agent.is_navigation_finished():
		velocity = Vector3.ZERO
		anim_player.stop()
		return

	var next_position = nav_agent.get_next_path_position()
	var direction = (next_position - global_transform.origin).normalized()
	velocity = direction * speed
	move_and_slide()

	if velocity.length() > 0.1:
		if anim_player.current_animation != "walking":
			anim_player.play("walking")
	else:
		anim_player.stop()

############################################################################################


func _on_player_detector_body_entered(body):
	if body.name == "Player":
		get_tree().reload_current_scene()
