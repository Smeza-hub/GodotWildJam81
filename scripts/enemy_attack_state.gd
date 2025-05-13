extends State
class_name EnemyAttackState

@export var actor: Enemy
@export var animator: AnimatedSprite2D

signal player_out_of_range

func _ready() -> void:
	set_physics_process(false)
	
	
func _enter_state()->void:
	actor.velocity = Vector2.ZERO
	actor.attack()
	animator.play("attack")
	await get_tree().create_timer(0.2).timeout
	set_physics_process(true)
func _exit_state()->void:
	set_physics_process(false)
	
func _physics_process(delta: float) -> void:
	if !actor.target.hitbox.overlaps_area(actor.hurt_box):
		player_out_of_range.emit()
