extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 2.5
const SENSITIVITY = 0.003
const MAX_STAMINA = 1.
const SPRINT_MULTI = 1.5


var stamina = MAX_STAMINA


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head = $Head
@onready var camera = $Head/Camera3D

var oxygen_bar = 100.0
var mask_on = true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func toggle_mask():
	mask_on = !mask_on
	
func oxygen_control():
	if mask_on:
		oxygen_bar -= .1
		if(oxygen_bar <= 0):
			print("you died")
	else:
		if(oxygen_bar < 100):
			oxygen_bar += .1
		
	
	
	print("oxygen level: ", oxygen_bar)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("mask"):
		toggle_mask()
		print("toggle mask - ", mask_on)
	
	oxygen_control()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#update velocities
	if direction:
			
		velocity.x = direction.x * (SPEED) * (1 + (Input.get_action_strength("sprint") * SPRINT_MULTI))
		velocity.z = direction.z * (SPEED) * (1 + (Input.get_action_strength("sprint") * SPRINT_MULTI))
		
	else:
		velocity.x = 0.0 #move_toward(velocity.x, 0, SPEED)
		velocity.z = 0.0 #move_toward(velocity.z, 0, SPEED)

	move_and_slide()
