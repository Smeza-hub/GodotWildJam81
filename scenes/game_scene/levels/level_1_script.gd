extends Node

signal level_won
signal level_lost
var level_state : LevelState
@export var objectives_list: Array[String]  =["obj 1","obj 2","obj 3"]
var objective_status:Dictionary = {}
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	
	if objectives_list != null:
		for i in objectives_list:
			objective_status[i] = false
	print(objectives_list)
	level_state = GameState.get_level_state(scene_file_path)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
