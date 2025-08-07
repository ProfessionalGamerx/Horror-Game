extends CharacterBody3D

@onready var nav_agent = get_node("NavigationAgent3D")
@onready var player = get_node("/root/TestHorror/Player")  # Adjust path if needed

enum {
	STATE_ROAMING,
	STATE_CHASING
}

var speed = 6.0
var roam_timer = 0.0
var roam_target = Vector3.ZERO
var memory_time = 0.0

const MEMORY_DURATION = 3.0
const KILL_DISTANCE = 1.5


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
	match current_state:
		STATE_ROAMING:
			if can_see_player():
				current_state = STATE_CHASING
				memory_time = MEMORY_DURATION
			else:
				roam(delta)

		STATE_CHASING:
			if can_see_player():
				memory_time = MEMORY_DURATION  # Reset memory if player is seen again
				chase(delta)
			else:
				memory_time -= delta
				if memory_time > 0:
					chase(delta)  # Keep chasing during memory time
				else:
					current_state = STATE_ROAMING


func roam(delta):
	roam_timer -= delta
	if roam_timer <= 0:
		# Pick a new random location within range
		var offset = Vector3(
			randf_range(-10, 10),
			0,
			randf_range(-10, 10)
		)
		roam_target = global_transform.origin + offset
		nav_agent.set_target_position(roam_target)
		roam_timer = 3.0  # Pick a new point every 3 seconds

	if nav_agent.is_navigation_finished():
		return

	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_transform.origin).normalized()
	velocity = direction * speed
	move_and_slide()

func chase(delta):
	nav_agent.set_target_position(player.global_transform.origin)

	if nav_agent.is_navigation_finished():
		return

	var next_position = nav_agent.get_next_path_position()
	var direction = (next_position - global_transform.origin).normalized()
	velocity = direction * speed
	move_and_slide()

	# Check if player is within kill range
	if global_transform.origin.distance_to(player.global_transform.origin) < KILL_DISTANCE:
		kill_player()

func kill_player():
	get_tree().get_root().get_node("Player").kill_player()
