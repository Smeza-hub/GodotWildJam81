extends StaticBody2D
class_name Interactable
@onready var interactablearea: Area2D = $interactablearea
var can_interact: bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func interact():
	if !can_interact:
		return
	modulate.a = 0.5
	
