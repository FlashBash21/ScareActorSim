extends Node

@export var basic_enemy : PackedScene
@export var spawn_points : Array[Vector3]
@export var wander_points : Array[Vector3]

@export var nav_area : NavigationRegion3D
@export var TEMP_PLAYER_REF : CharacterBody3D


var agents : Array[CharacterBody3D]

func _physics_process(delta: float) -> void:
	#order_all_agents(TEMP_PLAYER_REF.global_position)
	pass

func spawn_agent() -> void:
	var point = spawn_points.pick_random()
	if point:
		var enemy = basic_enemy.instantiate()
		add_child(enemy)
		enemy.global_position = point
		agents.append(enemy)
		enemy.request_new_pos.connect(find_new_pos)

#update all agents' target position
func order_all_agents(pos: Vector3) -> void:
	for agent in agents:
		agent.set_target_position(pos)

func _on_spawn_timer_timeout() -> void:
	if agents.size() < 10:
		spawn_agent()

func find_new_pos(ref):
	var point = wander_points.pick_random()
	if point:
		ref.set_target_position(point)
