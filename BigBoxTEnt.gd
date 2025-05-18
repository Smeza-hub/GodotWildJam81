extends Interactable

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var occlusionarea: Area2D = $occlusionarea

var exterior_diffuse = preload("res://Assets/Game Assets/Interactables/BIGBIGtent/big_big_BIG_tent_diffuse.png")
var exterior_normal = preload("res://Assets/Game Assets/Interactables/BIGBIGtent/big_big_BIG_tent_normal.png")
var interior_diffuse = preload("res://Assets/Game Assets/Interactables/BIGBIGtent/big_big_BIG_tent_no_room_diffuse.png")
var interior_normal = preload("res://Assets/Game Assets/Interactables/BIGBIGtent/big_big_BIG_tent_no_room_normal.png")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		sprite_2d.texture = interior_diffuse
		sprite_2d.self_modulate.a = 0.5


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		sprite_2d.texture = exterior_diffuse
		sprite_2d.self_modulate.a = 1
