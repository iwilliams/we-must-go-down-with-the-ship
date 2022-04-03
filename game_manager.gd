extends Node

var fillage = -.05

var holes = {}

var _main = null

func register_main(main):
    _main = main

func _physics_process(delta):
    var increase = (.00125 * holes.values().size()) * delta
    fillage += increase


func remove_hole(hole):
    holes.erase(hole.position)


func add_hole(hole):
    holes[hole.position] = hole
    if _main != null:
        hole.connect('hole_pressed', _main, 'on_hole_pressed')
