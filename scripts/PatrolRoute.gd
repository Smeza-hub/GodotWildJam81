@tool
extends Node2D
@export var points: Array[Vector2] = []

func _ready():
	if Engine.is_editor_hint():
		points.clear()
		for child in get_children():
			if child is Marker2D:
				points.append(child.global_position)
		notify_property_list_changed()
