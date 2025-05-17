class_name EnemyAttackState
extends State


@export var actor: Enemy
@export var animator: AnimatedSprite2D
@export var attack_timer: Timer
@onready var can_attack:bool = false
signal player_out_of_range

func _ready() -> void:
	attack_timer.connect("timeout",_on_timeout)
	set_physics_process(false)
	
	
func _enter_state()->void:
	actor.velocity = Vector2.ZERO
	attack()
	animator.play("attack")
	set_physics_process(true)
func _exit_state()->void:
	set_physics_process(false)
	
func _physics_process(delta: float) -> void:
	print(attack_timer.time_left)


func attack():
	actor.attack()
	animator.play("attack")
	can_attack = false
	attack_timer.start(actor.attack_cooldown)


func _on_timeout():
	emit_signal("player_out_of_range")
	
