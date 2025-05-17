class_name EnemyIdleState
extends State

@export var actor: Enemy
@export var animator:AnimatedSprite2D
@export var vision_area: Area2D
@export var vision_cone :CollisionShape2D
@export var animation_player: AnimationPlayer
@export var vision_cast: RayCast2D
@onready var fov_indicator: Sprite2D = %FOV_indicator

@onready var direction: Vector2 = Vector2.RIGHT
signal found_player

func _ready() -> void:
	set_physics_process(false)
	vision_area.connect("area_entered",_on_found_player)
	

func _enter_state()->void:
	fov_indicator.visible = true
	set_physics_process(true)
	animator.play("idle")
	animator.flip_h = false
	animation_player.reset_section()
	animation_player.play("ConeSweep")
	actor.velocity = Vector2.ZERO
func _exit_state() -> void:
	fov_indicator.visible = false
	set_physics_process(false)
	animation_player.stop()

func _physics_process(delta: float) -> void:
	actor.fov_indicator.rotation = vision_cone.rotation + PI
	actor.target_direction = Vector2.from_angle(vision_cone.rotation + PI/2).normalized()
	vision_cone.rotation
	direction = actor.global_position.direction_to(actor.target.global_position)
	vision_cast.target_position = direction.normalized() * 300
func _on_found_player(body):
	if !body.is_in_group("player_light"):
		return
	var collider = vision_cast.get_collider()
	if collider and collider.is_in_group("player"):
		emit_signal("found_player")
	
