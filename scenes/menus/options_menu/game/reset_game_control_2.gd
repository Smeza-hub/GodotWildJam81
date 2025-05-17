extends HBoxContainer


func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Global.visual_effects = true
		print(Global.visual_effects)
	else:
		Global.visual_effects = false
		print(Global.visual_effects)
