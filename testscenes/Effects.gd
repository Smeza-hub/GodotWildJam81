extends Node
class_name PotionEffects

static var glow_light = preload("res://testscenes/glow_light.tscn")
static var smoke_particle = preload("res://smoke_particle.tscn")
# Key is potion effect name. value is [tooltip, function]
static var positive_effects = {
	"health_rapid_mend":["heal instantly",Callable(PotionEffects,"health_rapid_mend")],
	"health_regeneration":["heal over time",Callable(PotionEffects,"health_regeneration")],
	"speed_boost":["speed_boost",Callable(PotionEffects,"speed_boost")]
}
static var negative_effects = {
	"maximize":["Grow in size",Callable(PotionEffects,"maximize")],
	"glow":["glow",Callable(PotionEffects,"glow")],
	"confusion":["confusion",Callable(PotionEffects,"confusion")]
}
#POSITIVE EFFECTS
static func health_rapid_mend(player:Player):
	player.health += player.health/4
	print("health_rapid_mend")

static func health_regeneration(player:Player):
	print("health_regeneration")
	for i in 5:
		player.health += player.health/20.0
		await player.get_tree().create_timer(1.0).timeout

static func speed_boost(player:Player):
	player.speed = player.BASE_SPEED * 2
	player.acceleration = player.BASE_ACCELERATION *2
	await player.get_tree().create_timer(5.0).timeout
	player.speed = player.BASE_SPEED
	player.acceleration = player.BASE_ACCELERATION 

#NEGATIVE EFFECTS
static func maximize(player:Player):
	player.sprite_2d.scale = player.BASE_SCALE * 2
	player.hitbox.scale = player.BASE_SCALE *2
	player.collision.scale = player.BASE_SCALE *2
	await player.get_tree().create_timer(4.0).timeout 
	player.sprite_2d.scale = player.BASE_SCALE
	player.hitbox.scale = player.BASE_SCALE 
	player.collision.scale = player.BASE_SCALE 

static func glow(player:Player):
	player.vision_hitbox.scale = Vector2(12,12)
	var g_light = glow_light.instantiate()
	player.add_child(g_light)
	await player.get_tree().create_timer(5.0).timeout
	player.vision_hitbox.scale = player.BASE_SCALE
	g_light.queue_free()

static func confusion(player:Player):
	player.is_confused = true
	var Inputs = ["left","right","up","down"]
	var shuffled_inputs = Inputs.duplicate()
	shuffled_inputs.shuffle()
	player.confused_dir = {
		"left":shuffled_inputs[0],
		"right":shuffled_inputs[1],
		"up":shuffled_inputs[2],
		"down":shuffled_inputs[3],
	}
	await player.get_tree().create_timer(10.0).timeout
	player.is_confused = false
