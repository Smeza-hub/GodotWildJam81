class_name EnemySearchState
extends State

@export var actor: Enemy
@export var animator: AnimatedSprite2D
@export var vision_cast: RayCast2D

signal search_failed
signal search_succeeded


func _ready() -> void:
	
	set_physics_process(false)

func _enter_state()->void:
	set_physics_process(true)
	animator.play("move")
	print("chasing")
	
func _exit_state()->void:
	set_physics_process(false)
	
func _physics_process(delta: float) -> void:
	if actor.nav_agent.is_navigation_finished():
		actor.velocity = Vector2.ZERO
		search_failed.emit()
		return
		
	var target_pos = actor.last_known_pos
	actor.nav_agent.target_position = target_pos
	
	var next_path_point = actor.nav_agent.get_next_path_position()
	var direction = (next_path_point - actor.global_position).normalized()
	actor.velocity = actor.velocity.move_toward(direction * actor.max_speed, actor.acceleration * delta)
	
	var base_scale_x = abs(animator.scale.x)
	
	animator.flip_h = actor.velocity.x < 0
	
	#var direction = actor.global_position.direction_to(actor.last_known_pos)
	#actor.velocity = actor.velocity.move_toward(direction * actor.max_speed, actor.acceleration * delta)
	vision_cast.target_position = actor.global_position.direction_to(actor.target.global_position) * 100
	
	if vision_cast.is_colliding():
		if vision_cast.get_collider().is_in_group("player"):
			search_succeeded.emit()
			
