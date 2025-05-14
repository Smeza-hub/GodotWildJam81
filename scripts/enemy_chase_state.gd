class_name EnemyChaseState
extends State

@export var actor: Enemy
@export var animator: AnimatedSprite2D
@export var vision_cast: RayCast2D
@export var chase_timer: Timer
@export var hurt_box:Area2D
var state_active: bool
signal lost_player
signal in_range
func _ready() -> void:
	set_physics_process(false)
	chase_timer.connect("timeout",_on_timeout)
	hurt_box.connect("area_entered",_in_range_of_player)
func _enter_state()->void:
	set_physics_process(true)
	animator.play("move")
	state_active = true
	
func _exit_state()->void:
	set_physics_process(false)
	chase_timer.stop()
	state_active = false
func _physics_process(delta: float) -> void:
	var target_pos = actor.target.global_position
	actor.nav_agent.target_position = target_pos
	
	var next_path_point = actor.nav_agent.get_next_path_position()
	var direction = (next_path_point - actor.global_position).normalized()
	actor.velocity = actor.velocity.move_toward(direction * actor.max_speed, actor.acceleration * delta)
	
	
	var base_scale_x = abs(animator.scale.x)
	if actor.velocity.x > 0:
		animator.flip_h = false
	elif actor.velocity.x < 0:
		animator.flip_h = true
		
	var tar_direction = actor.global_position.direction_to(actor.target.global_position)
	#actor.velocity = actor.velocity.move_toward(direction * actor.max_speed, actor.acceleration * delta)
	vision_cast.target_position = tar_direction.normalized() * 100
	
	if vision_cast.is_colliding():
		if !vision_cast.get_collider().is_in_group("player"):
			if chase_timer.time_left > 0.0:
				return
			else:
				chase_timer.start()
		else:
			chase_timer.stop()
	if !vision_cast.is_colliding():
		if chase_timer.time_left > 0.0:
			return
		else:
			chase_timer.start()
		
func _on_timeout():
	if !state_active: return
	lost_player.emit()
	actor.last_known_pos = actor.target.global_position
func _in_range_of_player(area):
	if area.is_in_group("player"):
		in_range.emit()
		print("reached player")
	else:
		return
