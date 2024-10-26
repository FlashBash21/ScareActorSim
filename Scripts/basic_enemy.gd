extends CharacterBody3D
class_name Enemy

signal request_new_pos(ref)
signal request_flee_pos(ref)

@onready var nav_agent = $NavigationAgent3D as NavigationAgent3D
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

const SPEED = 2.0

enum STATES {WANDERING, FLEEING}

var state = STATES.WANDERING

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity.y -= gravity
		
	if nav_agent.is_navigation_finished():
		request_new_pos.emit(self)
	var next_position := nav_agent.get_next_path_position()
	var direction := (next_position - global_position)
	direction.y = 0
	direction = direction.normalized()

	#global_position = global_position.move_toward(next_position, delta * SPEED)
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	
	look_at(global_position + direction, Vector3.UP)
	
	aimVisibilityStatus()
	
	move_and_slide()
	
	match state:
		STATES.WANDERING:
			pass
		STATES.FLEEING:
			pass


func set_target_position(target_position: Vector3):
	nav_agent.set_target_position(target_position)

func aimVisibilityStatus() -> void:
	if not $CuriousSprite.visible:
		return
	for body in $Visibility.get_overlapping_bodies():
		if (body is Player):
			updateVisibilityStatus(body)
			$CuriousSprite.look_at(body.global_position, Vector3.UP)
			$CuriousSprite.rotation.x = 0
		
func updateVisibilityStatus(player: Player) -> void:
	var distance = player.global_position - self.global_position
	if distance.length() <= 8:
		$CuriousSprite.texture = load("res://Assets/danger.png")
		request_flee_pos.emit(self)
	else:
		$CuriousSprite.texture = load("res://Assets/question mark.png")

func _on_visibility_body_entered(body: Node3D) -> void:
	if (body is Player):
		updateVisibilityStatus(body)
		$CuriousSprite.visible = true
		$CuriousSprite.look_at(body.global_position, Vector3.UP)


func _on_visibility_body_exited(body: Node3D) -> void:
	if (body is Player):
		$CuriousSprite.visible = false
