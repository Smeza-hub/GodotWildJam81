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
	var distance_to_last_known = actor.global_position.distance_to(actor.last_known_pos)
	var base_scale_x = abs(animator.scale.x)
	
	if actor.velocity.x > 0:
		animator.flip_h = false
	elif actor.velocity.x < 0:
		animator.flip_h = true
	
	var direction = actor.global_position.direction_to(actor.last_known_pos)
	actor.velocity = actor.velocity.move_toward(direction * actor.max_speed, actor.acceleration * delta)
	vision_cast.target_position = actor.global_position.direction_to(actor.target.global_position) * 100
	
	if vision_cast.is_colliding():
		if vision_cast.get_collider().is_in_group("player"):
			search_succeeded.emit()
			
	if distance_to_last_known < 50:
		actor.velocity = Vector2.ZERO
		search_failed.emit()
