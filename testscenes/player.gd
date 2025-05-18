extends CharacterBody2D
class_name Player

@export var level_node:Node


@export var BASE_SPEED: float = 500.0
@export var BASE_ACCELERATION: float = 2000
const BASE_HEALTH: float = 100
const SPRITE_BASE_SCALE = Vector2(1.84,1.84)
const BASE_SCALE: = Vector2(1.08, 1.08)
const BASE_TOLERANCE:float = 100

@onready var interactablearea: Area2D = $interactablearea
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var collision: CollisionShape2D = $Collision
@onready var vision_hitbox: Area2D = $VisionHitbox
@onready var camera_2d: Camera2D = $Camera2D
@onready var audio_listener_2d: AudioListener2D = $Camera2D/AudioListener2D
@onready var take_damage_audio: AudioStreamPlayer2D = $TakeDamage

@onready var intended_dir: RayCast2D = $Intended_dir
@onready var walk_audio: AudioStreamPlayer2D = $Walk

var last_facing_direction := Vector2(0,-1)
var Max_health: float = BASE_HEALTH
var health: float = BASE_HEALTH
@onready var potion_sound: AudioStreamPlayer2D = $PotionSound

var max_tolerance: float = BASE_TOLERANCE
var tolerance:float = 50
var is_drunk = false
var in_withdrawal = false
var drunk_delta = 0

var speed: float = BASE_SPEED
var acceleration: float = BASE_ACCELERATION
var potions_in_inventory = []
var party_value:float

var direction := Vector2.ZERO
var facing_angle: float = 0.0

var is_maximized:bool = false

var is_confused = false
var confused_dir: Dictionary = {}

var is_teleport_movement = false
var teleport_distance := 200.0
var last_input_direction := Vector2.ZERO

var smoke_shroud_active = false
var smoke_particle = preload("res://smoke_particle.tscn")

var nearby_interactables: Array =[]

signal player_died
signal player_damaged

var active_effects = {}

func _ready():
	print(Config.get_config(AppSettings.CUSTOM_SECTION, "DisableVisualEffects"))
	Global.player = self
	audio_listener_2d.make_current()
	speed = BASE_SPEED
	acceleration= BASE_ACCELERATION
	set_process_input(true)
func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		_interact()
func _physics_process(delta: float) -> void:
	drunk_delta+= delta
	var input_vector = Vector2.ZERO
	if is_teleport_movement:
		handle_teleport_movement()
		return
	var idle = !velocity
	if !is_confused:
		input_vector = Input.get_vector("left","right","up","down")
	elif is_confused:
		input_vector = Input.get_vector("right","left","down","up")
		
	if input_vector.length() >0.1:
		if is_drunk or in_withdrawal:
			var drunk_angle = sin(drunk_delta * 3) * 0.5
			input_vector = input_vector.rotated(drunk_angle).normalized()
		var target_angle = input_vector.angle()
		facing_angle = lerp_angle(facing_angle,target_angle,10.0*delta)
		last_facing_direction = velocity.normalized()
	
	
	animation_tree.set("parameters/Walk/blend_position",last_facing_direction)
	animation_tree.set("parameters/Idle/blend_position",last_facing_direction)
	var target_velocity = input_vector * speed
	velocity = velocity.move_toward(target_velocity ,acceleration * delta) 
	
	#if direction == Vector2.ZERO:
		#velocity = velocity.move_toward(Vector2.ZERO,5*delta)
		
	intended_dir.target_position = Vector2.RIGHT.rotated(facing_angle) * 100
	move_and_slide()
func _process(delta: float) -> void:
	_handle_tolerance(delta)
	_handle_walking_audio()
func _interact():
	if nearby_interactables.is_empty():
		return
	var closest = null
	var closest_dist = INF
	for obj in nearby_interactables:
		if obj.can_interact == false:
			continue
		var dist = global_position.distance_to(obj.global_position)
		if dist < closest_dist:
			closest = obj
			closest_dist = dist
	if closest:
		closest.interact()

func _on_interactablearea_area_entered(area: Area2D) -> void:
	if !area.is_in_group("interactable"):
		return
	var interact_object = area.get_parent()
	if interact_object not in nearby_interactables:
		nearby_interactables.append(interact_object)

func _on_interactablearea_area_exited(area: Area2D) -> void:
	var interact_object = area.get_parent()
	nearby_interactables.erase(interact_object)

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
	apply_effect(effect1)
	apply_effect(effect2)
	potion_sound.play()
func apply_effect(effect:Callable):
	var effect_name = effect.get_method()
	if active_effects.has(effect_name):
		if typeof(active_effects[effect_name]) == TYPE_BOOL:
			return
		if typeof(effect) == TYPE_CALLABLE:
			effect.call(self)
		else:
		# lambda
			effect.call()
		var timer: Timer = active_effects[effect_name]
		timer.start()
	else:
		effect.call(self)
func take_damage(amount,enemy,knockback):
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
		player_damaged.emit()
		take_damage_audio.play()
		health = clamp(health-amount,0,Max_health)
		if health < 1:
			level_node.level_lost.emit()
		velocity = Vector2.ZERO
		var enemy_direction = global_position.direction_to(enemy.global_position)
		velocity = -(enemy_direction * knockback)
func increase_tolerance():
	tolerance = clamp(tolerance + 20,0,100)
func _handle_tolerance(delta):
	tolerance = clamp(tolerance - (2 * delta), 0, 100)

	if tolerance <= max_tolerance * 0.20:
		is_drunk = false
		in_withdrawal = true
		health = clamp(health - 1 * delta, 0, Max_health)

	elif tolerance >= max_tolerance * 0.80:
		is_drunk = true
		in_withdrawal = false

	else:
		is_drunk = false
		in_withdrawal = false
func _handle_walking_audio():
	if velocity.length() >0:
		if !walk_audio.playing:
			print("playing audio")
			walk_audio.play()
	else:
		walk_audio.stop()
					
			
