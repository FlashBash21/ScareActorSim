extends CharacterBody3D
class_name Enemy

signal request_new_pos(ref)
signal request_flee_pos(ref)

@onready var nav_agent = $NavigationAgent3D as NavigationAgent3D
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

const SCARE_RADIUS = 8.
const SPEED = 2.0
var SPEED_MULTI = 1.

enum STATES {WANDERING, FLEEING}

var state := STATES.WANDERING

func _physics_process(delta: float) -> void:
	
	match state:
		STATES.WANDERING:
			SPEED_MULTI = 1.
			if nav_agent.is_navigation_finished():
				request_new_pos.emit(self)
			
			var body = get_nearest_player()
			if body and get_body_distance(body) < SCARE_RADIUS:
				request_flee_pos.emit(self)
				set_state(STATES.FLEEING)
			
		STATES.FLEEING:
			SPEED_MULTI = 3.
			if nav_agent.is_navigation_finished():
				
				set_state(STATES.WANDERING)
	
	#always get movement from nav_agent
	if not is_on_floor():
		velocity.y -= gravity
	
	var next_position := nav_agent.get_next_path_position()
	var direction := (next_position - global_position)
	direction.y = 0
	direction = direction.normalized()

	#global_position = global_position.move_toward(next_position, delta * SPEED)
	velocity.x = direction.x * SPEED * SPEED_MULTI
	velocity.z = direction.z * SPEED * SPEED_MULTI
	
	look_at(global_position + direction, Vector3.UP)
	update_visibility_status()
	move_and_slide()


func set_target_position(target_position: Vector3):
	nav_agent.set_target_position(target_position)

#point the status box at the given body
func aim_vsisibility_status(body: Node3D) -> void:
	$CuriousSprite.look_at(body.global_position, Vector3.UP)
	$CuriousSprite.rotation.x = 0
		
func update_visibility_status() -> void:
	var body = get_nearest_player()
	if not body:
		$CuriousSprite.visible = false
		return
		
	$CuriousSprite.visible = true
	aim_vsisibility_status(body)

	if get_body_distance(body) <= SCARE_RADIUS + 1:
		$CuriousSprite.texture = load("res://Assets/danger.png")
	else:
		$CuriousSprite.texture = load("res://Assets/question mark.png")

func get_body_distance(body: Node3D) -> float:
	return (body.global_position - self.global_position).length()

func _on_visibility_body_exited(body: Node3D) -> void:
	if (body is Player):
		$CuriousSprite.visible = false
		
func get_nearest_player() -> Player:
	for body in $Visibility.get_overlapping_bodies():
		if (body is Player):
			return body
	return null

func set_state(new_state: int) -> void:
	self.state = new_state
