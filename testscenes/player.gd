extends CharacterBody2D
class_name Player

const BASE_SPEED: float = 500.0
const BASE_ACCELERATION: float = BASE_SPEED *4
const BASE_HEALTH: float = 100
const BASE_SCALE: = Vector2(1.08, 1.08)
const BASE_TOLERANCE:float = 100
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var interactablearea: Area2D = $interactablearea
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var collision: CollisionShape2D = $Collision
@onready var vision_hitbox: Area2D = $VisionHitbox


var last_facing_direction := Vector2(0,-1)
var Max_health: float = BASE_HEALTH
var health: float = BASE_HEALTH
var max_tolerance: float = BASE_TOLERANCE
var tolerance:float = 0
var speed: float = BASE_SPEED
var acceleration: float = BASE_ACCELERATION
var potions_in_inventory = []
var party_value:float

func _ready():
	Global.player = self
	set_process_input(true)

func _physics_process(delta: float) -> void:
	var idle = !velocity
	var direction = Input.get_vector("left","right","up","down")
	if !idle:
		last_facing_direction = velocity.normalized()
	
	
	animation_tree.set("parameters/Idle/blend_position",last_facing_direction)
	animation_tree.set("parameters/Crouch/blend_position",last_facing_direction)
	velocity = velocity.move_toward(direction * speed ,acceleration * delta) 
	
	#if direction == Vector2.ZERO:
		#velocity = velocity.move_toward(Vector2.ZERO,5*delta)
		
	
	move_and_slide()

func _interact(area):
	area.interact()

func _on_interactablearea_area_entered(area: Area2D) -> void:
	var interact_object = area.get_parent()
	_interact(interact_object)

func _on_interactablearea_area_exited(area: Area2D) -> void:
	pass # Replace with function body.


#func _handle_animation(direction,velocity):
	#if velocity == vector2.ZERO:
		#pass
	#pass
#func switch_animation(animation):
	#var current_frame = animated_sprite.get_frame()
	#var current_progress = animated_sprite.get_frame_progress()
	#animated_sprite.play(animation)
	#animated_sprite.set_frame_and_progress(current_frame, current_progress)

func use_item(effect1,effect2):
	effect1.call(self)
	effect2.call(self)
	
func take_damage(amount,enemy:Enemy,knockback):
	health = clamp(health-amount,0,Max_health)
	velocity = Vector2.ZERO
	var enemy_direction = global_position.direction_to(enemy.global_position)
	velocity = -(enemy_direction * knockback)
	
func increase_tolerance():
	tolerance += 30
	
