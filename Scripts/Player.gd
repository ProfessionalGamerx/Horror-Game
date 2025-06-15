extends CharacterBody3D

@onready var ray: RayCast3D = $CameraPivot/Camera3D/InteractRay
@onready var hand = $CameraPivot/Camera3D/Hand

var held_object: Node3D = null

const SPEED = 5.0
const JUMP_VELOCITY = 5
const SPRINT_MULTIPLIER = 1.6

@export var mouse_sensitivity := 0.002
var yaw := 0.0
var pitch := 0.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$MeshInstance3D.visible = false
	
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
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Determine current speed
	var current_speed = SPEED
	if Input.is_action_pressed("sprint"):
		current_speed *= SPRINT_MULTIPLIER

	# Get input direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = Vector3(input_dir.x, 0, input_dir.y)
	direction = (global_transform.basis * direction).normalized()

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _process(delta):
	if Input.is_action_just_pressed("interact"):
		if held_object:
			if held_object.has_method("pickup"):
				held_object.pickup(null)
			held_object = null
			return
		elif ray.is_colliding():
			var hit = ray.get_collider()
			print("Ray hit:", hit)
			var node = hit
			while node:
				if node.has_method("pickup"):
					print("Found pickup method on:", node.name)
					node.pickup($CameraPivot/Camera3D/Hand)
					held_object = node
					return
				if node.has_method("interact"):
					print("Found interact method on:", node.name)
					node.interact()
					return
				node = node.get_parent()
			print("No interact method found on hit or any parent.")
