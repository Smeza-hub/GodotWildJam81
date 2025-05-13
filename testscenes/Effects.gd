extends Node
class_name PotionEffects

static var glow_light = preload("res://testscenes/glow_light.tscn")

# Key is potion effect name. value is [tooltip, function]
static var positive_effects = {
	"health_rapid_mend":["heal instantly",Callable(PotionEffects,"health_rapid_mend")],
	"health_regeneration":["heal over time",Callable(PotionEffects,"health_regeneration")],
}
static var negative_effects = {
	"maximize":["Grow in size",Callable(PotionEffects,"maximize")],
	"glow":["glow",Callable(PotionEffects,"glow")]
}

static func health_rapid_mend(player):
	player.health += player.health/4
	print("health_rapid_mend")

static func health_regeneration(player):
	print("health_regeneration")
	for i in 5:
		player.health += player.health/20.0
		await player.get_tree().create_timer(1.0).timeout

static func maximize(player:Player):
	player.sprite_2d.scale = player.BASE_SCALE * 3
	player.hitbox.scale = player.BASE_SCALE *3
	player.collision.scale = player.BASE_SCALE *3
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
