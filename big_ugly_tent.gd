extends Interactable
@onready var occlusionarea: Area2D = $occlusionarea

@onready var sprite_2d: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_occlusionarea_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		sprite_2d.modulate.a = 0.4

func _on_occlusionarea_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		sprite_2d.modulate.a = 1
