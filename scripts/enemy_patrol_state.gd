class_name EnemyPatrolState
extends State

@export var actor: Enemy
@export var vision_cast: RayCast2D
@export var vision_area:Area2D
@export var vision_cone :CollisionShape2D
@onready var fov_indicator: Sprite2D = %FOV_indicator

var patrol_points: Array[Vector2] 
var current_patrol_point:int
var last_patrol_point:int
var waiting: bool = false
@export var wait_timer:Timer
signal player_found

func _ready() -> void:
	current_patrol_point = 0
	last_patrol_point =0 
	wait_timer.timeout.connect(_on_wait_timeout)
	vision_area.connect("area_entered",_on_found_player)
	set_physics_process(false)

func _enter_state()->void:
	if actor.fov_indicator:
		actor.fov_indicator.visible = true
	patrol_points = actor.patrol_points
	current_patrol_point = last_patrol_point
	travel_to_point()
	waiting = false
	set_physics_process(true)
	
func _exit_state()->void:
	set_physics_process(false)
	
func _physics_process(delta: float) -> void:
	if waiting:
		return
	if actor.global_position.distance_to(patrol_points[current_patrol_point]) < 10:
		start_wait_timer()
	else:
		var next_pos = actor.nav_agent.get_next_path_position()
		var direction = (next_pos - actor.global_position).normalized()
		actor.target_direction = direction
		actor.velocity = actor.velocity.move_toward(direction * actor.max_speed, actor.acceleration * delta)
		
		var target_angle = direction.angle()
		actor.fov_indicator.rotation = target_angle  + PI/2
		vision_cone.rotation = target_angle  - PI/2
		vision_cast.target_position = actor.global_position.direction_to(actor.target.global_position) * 115


func travel_to_point():
	last_patrol_point = current_patrol_point
	print(current_patrol_point + 1)
	print(actor.patrol_points.size())
	current_patrol_point = (current_patrol_point + 1) % actor.patrol_points.size()
	actor.nav_agent.target_position = patrol_points[current_patrol_point]

func start_wait_timer():
	waiting = true
	actor.velocity = Vector2.ZERO
	wait_timer.wait_time = 1.5
	wait_timer.one_shot = true
	wait_timer.start()
	
func _on_wait_timeout():
	waiting = false
	travel_to_point()
	wait_timer.stop()
func _on_found_player(body):
	print("detected")
	if !body.is_in_group("player_light"):
		return
	var collider = vision_cast.get_collider()
	if collider and collider.is_in_group("player"):
		print("emitting")
		emit_signal("player_found")
