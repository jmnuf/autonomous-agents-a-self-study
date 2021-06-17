extends Control

onready var cc = $CC
onready var camera:Camera2D = $Camera2D
onready var boids_c:SpinBox = $CC/VC/BoidsCounter

var WorldS = preload("res://World.tscn")

var max_pos:Vector2 = Vector2(720, 540)
var movement = Vector2(1, 1)

func _physics_process(_delta):
	cc.rect_position += movement
	camera.position += movement
	if camera.position.y >= max_pos.y or camera.position.y <= 0:
		movement.y *= -1
	if camera.position.x >= max_pos.x or camera.position.x <= 0:
		movement.x *= -1


func _on_StartButton_pressed():
	var w = WorldS.instance()
	var root = get_tree().root
	visible = false
	root.add_child(w)
	yield(get_tree(), "idle_frame")
	w.flock.flock_size = boids_c.value
