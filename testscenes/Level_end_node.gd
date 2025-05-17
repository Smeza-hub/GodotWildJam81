extends Interactable
@export var level_node:Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func interact():
	modulate.a = 0.5
	level_node.level_won.emit()
	
