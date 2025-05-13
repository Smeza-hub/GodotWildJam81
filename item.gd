extends Node
class_name Effects

var potion_type = []
static var potion_effect = {
	"health_rapid_mend":Callable(Effects,"health_rapid_mend"),
	
}

static func health_rapid_mend(player):
	player.health += player.health/4

static func health_regeneration(player):
	player.health
