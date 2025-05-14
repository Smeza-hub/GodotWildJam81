extends Control
@onready var button: Button = $HBoxContainer/Slot1/Button
@onready var button_2: Button = $HBoxContainer/Slot2/Button2
@onready var button_3: Button = $HBoxContainer/Slot3/Button3
@onready var potion_texture_1: TextureRect = $HBoxContainer/Slot1/PotionTexture1
@onready var potion_texture_2: TextureRect = $HBoxContainer/Slot2/PotionTexture2
@onready var potion_texture_3: TextureRect = $HBoxContainer/Slot3/PotionTexture3
@onready var slot_textures = [potion_texture_1,potion_texture_2,potion_texture_3]
@onready var potion_timer: Timer = $PotionTimer

@onready var potion_slot_1_body: RigidBody2D = %PotionSlot1Body
@onready var potion_slot_2_body: RigidBody2D = %PotionSlot2Body
@onready var potion_slot_3_body: RigidBody2D = %PotionSlot3Body

@onready var potion_slot_1_sprite: AnimatedSprite2D = %PotionSlot1Sprite
@onready var potion_slot_2_sprite: AnimatedSprite2D = %PotionSlot2Sprite
@onready var potion_slot_3_sprite: AnimatedSprite2D = %PotionSlot3Sprite

@onready var collision_polygon_2d: CollisionPolygon2D = %CollisionPolygon2D
@onready var collision_polygon_2d_2: CollisionPolygon2D = %CollisionPolygon2D2
@onready var collision_polygon_2d_3: CollisionPolygon2D = %CollisionPolygon2D3

@onready var h_box_container: HBoxContainer = $HBoxContainer


@export var player: CharacterBody2D
@onready var slots = [
	button,
	button_2,
	button_3,
]
@onready var potion_sprites =[
	potion_slot_1_sprite,
	potion_slot_2_sprite,
	potion_slot_3_sprite
]
var potions_in_inventory = []
var potion_slot_1 = null
var potion_slot_2 = null
var potion_slot_3 = null
var can_drink = true
var is_swaying = false
func _ready() -> void:
	update_slots()
	turn_off_shader(potion_slot_1_sprite)
	
func _process(delta: float) -> void:
	for i in slots.size():
		if slots[i].has_focus():
			turn_on_shader(potion_sprites[i])
		else:
			turn_off_shader(potion_sprites[i])
		
	
	var direction = Input.get_axis("right","left")
	
	if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		if is_swaying:
			return
		else:
			apply_sway_cont()
			is_swaying = true
			await get_tree().create_timer(randf_range(0.3,0.8)).timeout
			is_swaying = false
	 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left"):
		apply_sway_inst(-1)
	if event.is_action_pressed("right"):
		apply_sway_inst(1)
	if event.is_action_pressed("Get new potion"):
		print("generating potion")
		_generate_potion()
	if event.is_action_released("Use potion"):
		var focused = get_viewport().gui_get_focus_owner()
		if focused is Button:
			focused.emit_signal("pressed")
	if event.is_action_pressed("Slot 1"):
		slots[0].grab_focus()
	if event.is_action_pressed("Slot 2"):
		slots[1].grab_focus()
		print("focus 2")
	if event.is_action_pressed("Slot 3"):
		slots[2].grab_focus()
		print("focus 3")
	
func _on_slot_1_pressed() -> void:
	if potion_slot_1 != null and can_drink :
		player.use_item(potion_slot_1[0][1], potion_slot_1[1][1])
		potion_slot_1 = null
		player.increase_tolerance()
		potion_timer.start(3)
		can_drink = false
		update_slots()

func _on_slot_2_pressed() -> void:
	if potion_slot_2 != null and can_drink:
		player.use_item(potion_slot_2[0][1], potion_slot_2[1][1])
		potion_slot_2 = null
		player.increase_tolerance()
		potion_timer.start(3)
		can_drink = false
		update_slots()

func _on_slot_3_pressed() -> void:
	if potion_slot_3 != null and can_drink:
		player.use_item(potion_slot_3[0][1], potion_slot_3[1][1])
		potion_slot_3 = null
		player.increase_tolerance()
		potion_timer.start(3)
		can_drink = false
		update_slots()

func _generate_potion():
	var keys1 = Effect.positive_effects.keys()
	var keys2 = Effect.negative_effects.keys()

	var rand_key1 = keys1[randi() % keys1.size()]
	var rand_key2 = keys2[randi() % keys2.size()]
	
	var effect1 = Effect.positive_effects[rand_key1]
	var effect2 = Effect.negative_effects[rand_key2]
	
	var potion = [effect1, effect2]

	if potion_slot_1 == null:
		potion_slot_1 = potion
	elif potion_slot_2 == null:
		potion_slot_2 = potion
	elif potion_slot_3 == null:
		potion_slot_3 = potion
	else:
		print("Inventory full")
	update_slots()


func update_slots():
	
	potion_slot_1_sprite.visible = potion_slot_1!=null
	potion_slot_2_sprite.visible = potion_slot_2!=null
	potion_slot_3_sprite.visible = potion_slot_3!=null

	collision_polygon_2d.disabled = potion_slot_1==null
	collision_polygon_2d_2.disabled = potion_slot_2==null
	collision_polygon_2d_3.disabled = potion_slot_3==null
	
	
	
func _on_potion_timer_timeout() -> void:
	can_drink = true

func apply_sway_inst(direction:float):
	var sway_force = Vector2(randi_range(-1,1) * 3000.0, 0)
	potion_slot_1_body.apply_force(direction * sway_force)
	potion_slot_2_body.apply_force(direction * sway_force)
	potion_slot_3_body.apply_force(direction * sway_force)
func apply_sway_cont():
		var sway_force1 = Vector2(randi_range(-1,1) * 1000.0, 0)
		var sway_force2 = Vector2(randi_range(-1,1) * 1000.0, 0)
		var sway_force3 = Vector2(randi_range(-1,1) * 1000.0, 0)
		potion_slot_1_body.apply_force(sway_force1)
		potion_slot_2_body.apply_force(sway_force2)
		potion_slot_3_body.apply_force(sway_force3)
func turn_off_shader(sprite):
	sprite.material.set_shader_parameter("line_thickness",0.0)
	sprite.material.set_shader_parameter("line_color",Color(0,0,0,0))
func turn_on_shader(sprite):
	sprite.material.set_shader_parameter("line_thickness",3)
	sprite.material.set_shader_parameter("line_color",Color(255,255,255,255))
