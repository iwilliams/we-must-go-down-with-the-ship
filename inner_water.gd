extends ColorRect


func _physics_process(delta):
    material.set_shader_param('fillage', GameManager.fillage)
