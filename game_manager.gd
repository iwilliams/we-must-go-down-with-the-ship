extends Node

var max_x = 1280
var min_tile = 31
var max_tile = 47
var fillage = 0.0

var holes = {}

var _main = null

var selected_sailor = null

var score = 0

func register_main(main):
    _main = main

func _physics_process(delta):
    var increase = (.00125 * holes.values().size()) * delta
    fillage += increase


func remove_hole(hole):
    holes.erase(hole.position)


func add_hole(hole):
    holes[hole.position] = hole
    hole.connect('hole_fixed', self, '_on_hole_fixed')
    if _main != null:
        hole.connect('hole_pressed', _main, 'on_hole_pressed')


func _on_hole_fixed():
    score += 200
