extends Control

@export var player: Player
# Called when the node enters the scene tree for the first time.
@onready var health_bar: ProgressBar = $HealthBar
@onready var party_meter: ProgressBar = $PartyMeter
@onready var tolerance_bar: ProgressBar = $ToleranceBar


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	health_bar.value = player.health
	health_bar.max_value = player.Max_health
	tolerance_bar.value = player.tolerance
	tolerance_bar.max_value = player.max_tolerance
