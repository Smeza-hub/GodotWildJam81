extends Control



@onready var v_box_container: VBoxContainer = $VBoxContainer

@export var player: Player
# Called when the node enters the scene tree for the first time.
@onready var health_bar: ProgressBar = $HealthBar
@onready var party_meter: ProgressBar = $PartyMeter
@onready var tolerance_bar: ProgressBar = $ToleranceBar
@export var level_node: Node
# Called every frame. 'delta' is the elapsed time since the previous frame.
var mission_objectives = []

func _ready() -> void:
	set_process(false)
	if level_node != null:
		mission_objectives = level_node.objectives_list
		update_objectives(mission_objectives)
		set_process(true)
	else:
		print("level_node is still null")
func _process(delta: float) -> void:
	health_bar.value = player.health
	health_bar.max_value = player.Max_health
	tolerance_bar.value = player.tolerance
	tolerance_bar.max_value = player.max_tolerance
	update_objectives(mission_objectives)
	
func update_objectives(objectives: Array):
	for child in v_box_container.get_children():
		child.queue_free()

	for objective in objectives:
		var label = RichTextLabel.new()
		label.bbcode_enabled = true
		label.fit_content = true

		var is_complete = level_node.objective_status.get(objective, false)
		if is_complete:
			label.text = "[s][color=gray]- %s[/color][/s]" % objective
		else:
			label.text = "- " + objective

		v_box_container.add_child(label)
