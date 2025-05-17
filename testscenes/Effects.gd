extends Node
class_name PotionEffects

static var glow_light = preload("res://testscenes/glow_light.tscn")
static var smoke_particle = preload("res://smoke_particle.tscn")
# Key is potion effect name. value is [tooltip, function]
static var positive_effects = {
	"health_rapid_mend":["heal instantly",Callable(PotionEffects,"health_rapid_mend")],
	"health_regeneration":["heal over time",Callable(PotionEffects,"health_regeneration")],
	"speed_boost":["speed_boost",Callable(PotionEffects,"speed_boost")],
	"minimize":["minimize",Callable(PotionEffects,"minimize")],
}
static var negative_effects = {
	"maximize":["Grow in size",Callable(PotionEffects,"maximize")],
	"glow":["glow",Callable(PotionEffects,"glow")],
	"confusion":["confusion",Callable(PotionEffects,"confusion")]
}

static func handle_effect_timer(player:Player,duration:float,apply:Callable,reset:Callable):
	if apply.is_valid():
		apply.call()
	await player.get_tree().create_timer(duration).timeout
	if reset.is_valid():
		reset.call()
	
static func dot_effect(player:Player,name:String,duration:float,ticks:int,apply:Callable):
	if player.active_effects.has(name):
		return
	
	player.active_effects[name] = true
	
	var wait_time = duration/ticks
	for i in ticks:
		apply.call()
		await player.get_tree().create_timer(wait_time).timeout
	player.active_effects.erase(name)
	
	


#POSITIVE EFFECTS
static func health_rapid_mend(player:Player):
	player.health += player.Max_health/4
	print("health_rapid_mend")

static func health_regeneration(player:Player):
	dot_effect(
		player,
		"health_regeneration",
		5,
		5,
		func():
			player.health += player.Max_health/15
	)

static func speed_boost(player:Player):
	handle_effect_timer(
	player,
	5,
	func():
		player.speed = player.BASE_SPEED * 2
		player.acceleration = player.BASE_ACCELERATION *2,
	func():
		player.speed = player.BASE_SPEED
		player.acceleration = player.BASE_ACCELERATION 
	)
static func smoke_shroud(player:Player):
	handle_effect_timer(
	player,
	5,
	func():
		player.smoke_shroud_active = true,
	func():
		player.smoke_shroud_active = false
	)
static func minimize(player:Player):
	handle_effect_timer(
		player,
		5,
		func():
			player.speed = player.BASE_SPEED * 1.5
			player.acceleration = player.BASE_ACCELERATION *1.5
			player.sprite_2d.scale = player.SPRITE_BASE_SCALE * 0.5
			player.hitbox.scale = player.BASE_SCALE *0.5
			player.collision.scale = player.BASE_SCALE *0.5,
		func():
			player.sprite_2d.scale = player.SPRITE_BASE_SCALE
			player.hitbox.scale = player.BASE_SCALE
			player.collision.scale = player.BASE_SCALE
			player.speed = player.BASE_SPEED
			player.acceleration = player.BASE_ACCELERATION,
	)

	

#NEGATIVE EFFECTS
static func maximize(player:Player):
	handle_effect_timer(
		player,
		5,
		func():
			player.sprite_2d.scale = player.SPRITE_BASE_SCALE * 2
			player.hitbox.scale = player.BASE_SCALE *2
			player.collision.scale = player.BASE_SCALE *2,
		func():
			player.sprite_2d.scale = player.SPRITE_BASE_SCALE
			player.hitbox.scale = player.BASE_SCALE
			player.collision.scale = player.BASE_SCALE,
		
	)

static func glow(player:Player):
	var g_light = glow_light.instantiate()
	handle_effect_timer(player,
	5,
	func():
		player.vision_hitbox.scale = Vector2(12,12)
		player.add_child(g_light),
	func():
		player.vision_hitbox.scale = player.BASE_SCALE
		g_light.queue_free()
		)


static func confusion(player:Player):
	handle_effect_timer(player,
	5,
	func():
		player.is_confused = true
		var Inputs = ["left","right","up","down"]
		var shuffled_inputs = Inputs.duplicate()
		shuffled_inputs.shuffle()
		player.confused_dir = {
			"left":shuffled_inputs[0],
			"right":shuffled_inputs[1],
			"up":shuffled_inputs[2],
			"down":shuffled_inputs[3],
		},
	func():
		player.is_confused = false
		)
	
	
