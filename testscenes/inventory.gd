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
@onready var health_vial_body: RigidBody2D = $"SubViewportContainer/SubViewport/Node2D/Health Vial/HealthVialBody"
@onready var withdrawal_vial_body: RigidBody2D = $"SubViewportContainer/SubViewport/Node2D/Withdrawal Vial/WithdrawalVialBody"

@onready var portrait_sprite: Sprite2D = %PortraitSprite

@onready var potion_slot_1_sprite: AnimatedSprite2D = %PotionSlot1Sprite
@onready var potion_slot_2_sprite: AnimatedSprite2D = %PotionSlot2Sprite
@onready var potion_slot_3_sprite: AnimatedSprite2D = %PotionSlot3Sprite

@onready var collision_polygon_2d: CollisionPolygon2D = %CollisionPolygon2D
@onready var collision_polygon_2d_2: CollisionPolygon2D = %CollisionPolygon2D2
@onready var collision_polygon_2d_3: CollisionPolygon2D = %CollisionPolygon2D3

@onready var h_box_container: HBoxContainer = $HBoxContainer
@onready var drunkeffects: ColorRect = $Drunkeffects
@onready var health_sprite: AnimatedSprite2D = %"Health Sprite"
@onready var withdrawal_sprite: AnimatedSprite2D = %WithdrawalSprite
@onready var animation_tree: AnimationTree = $SubViewportContainer2/SubViewport2/AnimationTree

var drunk :bool = false
var took_damage:bool = false
var chugged:bool = false

@export var player: Player
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

var HealthSprite_base_y_scale = 0.084

var potion_slot_1 = null
var potion_slot_2 = null
var potion_slot_3 = null
var potions_in_inventory = [potion_slot_1,potion_slot_2,potion_slot_3]
var can_generate = true
var is_swaying = false
func _ready() -> void:
	animation_tree.active = true
	drunkeffects.visible = false
	update_slots()
	turn_off_shader(potion_slot_1_sprite)
	player.player_damaged.connect(_took_damage)

func _process(delta: float) -> void:
	var h_target_scale_y = clamp(HealthSprite_base_y_scale * (player.health / player.Max_health), 0, HealthSprite_base_y_scale)
	var w_target_scale_y = clamp(HealthSprite_base_y_scale * (player.tolerance / player.max_tolerance), 0, HealthSprite_base_y_scale)
	health_sprite.scale.y = lerp(health_sprite.scale.y, h_target_scale_y, delta * 10.0)
	withdrawal_sprite.scale.y = lerp(withdrawal_sprite.scale.y, w_target_scale_y, delta * 10.0)
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
	if Config.get_config(AppSettings.CUSTOM_SECTION, "DisableVisualEffects"):
		return
	else:
		if player.is_drunk or player.in_withdrawal:
			drunkeffects.visible = true
			var tween = create_tween()
			var drunk_refraction = drunkeffects.material
			tween.tween_property(drunk_refraction,"shader_parameter/refraction_strength",0.02,1.0)
		else:
			var tween = create_tween()
			var drunk_refraction = drunkeffects.material
			tween.tween_property(drunk_refraction,"shader_parameter/refraction_strength",0,1.0)
			await tween.finished
			drunkeffects.visible = false
	if player.in_withdrawal or player.is_drunk:
		drunk = true
	else:
		drunk = false
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
	if potion_slot_1 != null:
		player.use_item(potion_slot_1[0][1], potion_slot_1[1][1])
		potion_slot_1 = null
		player.increase_tolerance()
		update_slots()
		_chugged()

func _on_slot_2_pressed() -> void:
	if potion_slot_2 != null:
		player.use_item(potion_slot_2[0][1], potion_slot_2[1][1])
		potion_slot_2 = null
		player.increase_tolerance()
		update_slots()
		_chugged()

func _on_slot_3_pressed() -> void:
	if potion_slot_3 != null:
		player.use_item(potion_slot_3[0][1], potion_slot_3[1][1])
		potion_slot_3 = null
		player.increase_tolerance()
		update_slots()
		_chugged()

func _generate_potion():
	if can_generate:
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
		can_generate = false
		await get_tree().create_timer(1.0).timeout
		can_generate = true

func update_slots():
	
	potion_slot_1_sprite.visible = potion_slot_1!=null
	potion_slot_2_sprite.visible = potion_slot_2!=null
	potion_slot_3_sprite.visible = potion_slot_3!=null

	collision_polygon_2d.disabled = potion_slot_1==null
	collision_polygon_2d_2.disabled = potion_slot_2==null
	collision_polygon_2d_3.disabled = potion_slot_3==null
	
	potions_in_inventory = [potion_slot_1,potion_slot_2,potion_slot_3]
	var current_focus = get_viewport().gui_get_focus_owner()
	if current_focus in slots:
		var index = slots.find(current_focus)
		if potions_in_inventory[index] != null:
			return
	
	for i in slots.size():
		if potions_in_inventory[i] !=null:
			slots[i].grab_focus()
			break

func _on_potion_timer_timeout() -> void:
	can_generate = true

func apply_sway_inst(direction:float):
	var sway_force = Vector2(randi_range(-1,1) * 3000.0, 0)
	potion_slot_1_body.apply_force(direction * sway_force)
	potion_slot_2_body.apply_force(direction * sway_force)
	potion_slot_3_body.apply_force(direction * sway_force)
	withdrawal_vial_body.apply_force(direction*sway_force)
	health_vial_body.apply_force(direction*sway_force)
func apply_sway_cont():
		var sway_force1 = Vector2(randi_range(-1,1) * 1000.0, 0)
		var sway_force2 = Vector2(randi_range(-1,1) * 1000.0, 0)
		var sway_force3 = Vector2(randi_range(-1,1) * 1000.0, 0)
		var sway_force4 = Vector2(randi_range(-1,1) * 1000.0, 0)
		var sway_force5 = Vector2(randi_range(-1,1) * 1000.0, 0)
		potion_slot_1_body.apply_force(sway_force1)
		potion_slot_2_body.apply_force(sway_force2)
		potion_slot_3_body.apply_force(sway_force3)
		withdrawal_vial_body.apply_force(sway_force4)
		health_vial_body.apply_force(sway_force5)
func turn_off_shader(sprite):
	sprite.material.set_shader_parameter("line_thickness",0.0)
	sprite.material.set_shader_parameter("line_color",Color(0,0,0,0))
func turn_on_shader(sprite):
	sprite.material.set_shader_parameter("line_thickness",3)
	sprite.material.set_shader_parameter("line_color",Color(255,255,255,255))

func _chugged():
	if animation_tree.get("parameters/playback").get_current_node() == "Drink potion":
		await get_tree().create_timer(0.2).timeout
		animation_tree.get("parameters/playback").start("Drink potion")
	else:
		animation_tree.get("parameters/playback").travel("Drink potion")
func _took_damage():
	took_damage = true
	await get_tree().create_timer(0.1).timeout
	took_damage = false
