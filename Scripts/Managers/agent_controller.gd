extends Node

## The Scene which the controller spawns
@export var basic_enemy : PackedScene
## An array of spawn points to use
@export var spawn_points : Array[Vector3]
## An array of points which agents can wander to
@export var wander_points : Array[Vector3]
## If enabled, controller will look for WanderPoint children to use for the wander_points array. Any other values in the array will be ignored
@export var physical_wander_points : bool
## NOT IMPLEMENTED: If enabled, controller will look for SpawnPoint children to use for the spawn_points array. Any other values in the array will be ignored
@export var phyiscal_spawn_points : bool

@export var nav_area : NavigationRegion3D
@export var TEMP_PLAYER_REF : CharacterBody3D


var agents : Array[CharacterBody3D]

func _ready():
	if physical_wander_points:
		wander_points.clear()
		for child in get_children():
			child = child as WanderPoint
			if child:
				wander_points.append(child.global_position)

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
		enemy.request_flee_pos.connect(find_flee_pos)

#update all agents' target position
func order_all_agents(pos: Vector3) -> void:
	for agent in agents:
		agent.set_target_position(pos)

func _on_spawn_timer_timeout() -> void:
	if agents.size() < 10:
		spawn_agent()

func find_new_pos(ref) -> void:
	var point = wander_points.pick_random()
	if point:
		ref.set_target_position(point)

func find_flee_pos(ref) -> void:
	var query_pos = wander_points.duplicate()
	while true:
		var point = query_pos.pick_random()
		var dir_to_point = ref.global_position.direction_to(point)
		var dir_to_player = ref.global_position.direction_to(TEMP_PLAYER_REF.global_position)
		if dir_to_player.dot(dir_to_point) < 0:
			ref.set_target_position(point)
			return
		query_pos.erase(point)
	
