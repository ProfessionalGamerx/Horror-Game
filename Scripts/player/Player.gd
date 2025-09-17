extends CharacterBody3D

@onready var ray: RayCast3D = $CameraPivot/Camera3D/InteractRay
@onready var hand = $CameraPivot/Camera3D/Hand
@onready var interaction_prompt := get_tree().get_current_scene().get_node("UI/InteractionPrompt")
@onready var step_checks = $StepChecks
@onready var player_objective = $"../UI/Objective"

var prompt_visible = false

var held_object: Node3D = null

const SPEED = 5.0
const JUMP_VELOCITY = 5
const SPRINT_MULTIPLIER = 1.4
const STEP_HEIGHT = 0.4
const MAX_STEP_SLOPE = deg_to_rad(45)  # Only step on slopes less than 45 degrees

@export var mouse_sensitivity := 0.002
var yaw := 0.0
var pitch := 0.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$MeshInstance3D.visible = false
	current_objective()
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, deg_to_rad(-80), deg_to_rad(80))
		
		# Rotate the player body (yaw only)
		rotation.y = yaw

		# Rotate the camera pivot (pitch only)
		$CameraPivot.rotation.x = pitch


func _physics_process(delta):
	var current_speed = SPEED
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Determine current speed
	if Input.is_action_pressed("sprint"):
		current_speed *= SPRINT_MULTIPLIER

	# Get input direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = Vector3(input_dir.x, 0, input_dir.y)
	direction = (global_transform.basis * direction).normalized()

	# Apply movement
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed

		# Step check - loop through each RayCast3D
		for check in step_checks.get_children():
			if check is RayCast3D and check.is_colliding():
				var hit_normal = check.get_collision_normal()
				var hit_position = check.get_collision_point()

		# Check that the hit surface is horizontal enough
				var surface_angle = hit_normal.angle_to(Vector3.UP)
				if surface_angle > MAX_STEP_SLOPE:
					continue  # Too steep (like a wall), skip it

		# Check the height difference
				var step_height = hit_position.y - global_transform.origin.y
				if step_height > 0 and step_height < STEP_HEIGHT:
					translate(Vector3(0, STEP_HEIGHT, 0))
					break
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _process(delta):
	var show_prompt = false

	if held_object:
		show_prompt = false
	elif ray.is_colliding():
		var hit = ray.get_collider()
		var node = hit
		while node:
			if node.has_method("interact") or node.has_method("pickup"):
				show_prompt = true
				break
			node = node.get_parent()

	# Toggle the visibility of the prompt
	interaction_prompt.visible = show_prompt

	# Handle interaction
	if Input.is_action_just_pressed("interact"):
		if held_object:
			if held_object.has_method("pickup"):
				held_object.pickup(null)
			held_object = null
			return
		elif ray.is_colliding():
			var hit = ray.get_collider()
			var node = hit
			while node:
				if node.has_method("pickup"):
					node.pickup(hand)
					held_object = node
					return
				if node.has_method("interact"):
					node.interact()
					return
				node = node.get_parent()

func current_objective():
	var scene = get_tree().current_scene
	if scene.name == "Neighborhood" and Global.interactedWithPotOfGold == false:
		if Global.interactedWithLittleMan == false:
			player_objective.text = "Talk to the Funny looking Man"
		elif Global.interactedWithLittleMan == true:
			player_objective.text = "Good boy! now go to your Lamborghini"
	elif scene.name == "TestHorror":
		player_objective.text = "You have arrived at his wife's last known address"
		await get_tree().create_timer(8).timeout
		player_objective.text = "She's gone insane in this maze, be careful of her!"
		await get_tree().create_timer(8).timeout
		player_objective.text = "Retrieve the Pot of Gold at the end of the Maze"
		await get_tree().create_timer(12).timeout
		player_objective.text = "Those patches of blood might lead the way out!"
	elif scene.name == "Neighborhood" and Global.interactedWithPotOfGold == true:
		player_objective.text = "Speak with the Little Man for your reward"
	else:
		print("No corresponding scene found.")
