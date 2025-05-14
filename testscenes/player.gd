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
var direction := Vector2.ZERO

var is_confused = false
var confused_dir: Dictionary = {}

var is_teleport_movement = true
var teleport_distance := 200.0
var last_input_direction := Vector2.ZERO

var smoke_shroud_active = false
var smoke_particle = preload("res://smoke_particle.tscn")


func _ready():
	Global.player = self
	set_process_input(true)

func _physics_process(delta: float) -> void:
	
	if is_teleport_movement:
		handle_teleport_movement()
		return
	var idle = !velocity
	if !is_confused:
		direction = Input.get_vector("left","right","up","down")
	elif is_confused:
		direction = Input.get_vector(
			confused_dir["left"],
			confused_dir["right"],
			confused_dir["up"],
			confused_dir["down"]
		)
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
func handle_teleport_movement():
	var input_dir: Vector2
	if is_confused:
			input_dir = Input.get_vector(
			confused_dir["left"],
			confused_dir["right"],
			confused_dir["up"],
			confused_dir["down"])
	else:
		input_dir = Input.get_vector("left", "right", "up", "down")
	if input_dir != Vector2.ZERO and input_dir != last_input_direction:
		var new_position = global_position + input_dir.normalized() * teleport_distance
		
		var col_check = PhysicsShapeQueryParameters2D.new()
		var motion = new_position - global_position
		var shape = collision.shape
		var radius = shape.radius
		col_check.shape = collision.shape
		col_check.transform = Transform2D(0,new_position)
		col_check.exclude = [self]
		col_check.motion = motion

		var result = get_world_2d().direct_space_state.cast_motion(col_check)
		var safe_fraction = result[0]
		print(result)
		if  safe_fraction !=0:
			global_position += (new_position-global_position)*safe_fraction
		else:
			global_position = new_position
		last_input_direction = input_dir
		
		last_facing_direction = input_dir.normalized()
		animation_tree.set("parameters/Idle/blend_position", last_facing_direction)
		animation_tree.set("parameters/Crouch/blend_position", last_facing_direction)
	elif input_dir == Vector2.ZERO:
		last_input_direction = Vector2.ZERO
func use_item(effect1,effect2):
	effect1.call(self)
	effect2.call(self)
	
func take_damage(amount,enemy:Enemy,knockback):
	print("attacked")
	if smoke_shroud_active:
		var new_smoke_particle = smoke_particle.instantiate()
		new_smoke_particle.global_position = global_position
		get_parent().add_child(new_smoke_particle)
		var starting_position = global_position
		var random_offset = + Vector2(randi_range(-1,1),randi_range(-1,1)).normalized()* 500 
		var ending_position = starting_position + random_offset
		
		var tp_check = PhysicsShapeQueryParameters2D.new()
		tp_check.shape = collision
		tp_check.transform = Transform2D(0,starting_position)
		tp_check.exclude = [self]
		tp_check.motion = ending_position - starting_position
		tp_check.collision_mask = 5
		
		var result = get_world_2d().direct_space_state.cast_motion(tp_check)
		if result:
			global_position = starting_position.lerp(ending_position, result.safe_fraction)
			print("collision detected")
		else:
			global_position = ending_position
			print("no collision detected")
		var new_smoke_particle2 = smoke_particle.instantiate()
		add_child(new_smoke_particle2)
	else:
		health = clamp(health-amount,0,Max_health)
		velocity = Vector2.ZERO
		var enemy_direction = global_position.direction_to(enemy.global_position)
		velocity = -(enemy_direction * knockback)
	
func increase_tolerance():
	tolerance += 30
	
