extends AudioListener2D

var camera_position
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.camera = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if camera_position == null:
		return
		
