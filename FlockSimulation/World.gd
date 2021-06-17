extends Node2D

onready var flock = $Flock
onready var cam   = $Camera2D
onready var label = $CanvasLayer/Control/Panel/Margin/V/ActiveLabel

var active_boid:int = 0
var text := PoolStringArray()

func _ready():
	remove_child(cam)
	var a = flock.get_child(active_boid)
	a.add_child(cam)
	a.sprite.frame = 1
	text.append("Active boid: " + str(active_boid + 1) + "/" + str(flock.get_child_count()))
	var data = a.boid_data()
	text.append("Position: " + str(data["pos"]))
	text.append("Velocity: " + str(data["vel"]))
	text.append("Controlling: " + str(a.in_control))

func _process(_delta):
	user_inputs()
	var data = flock.get_child(active_boid).boid_data()
	data["pos"] = _to_int(data["pos"])
	data["vel"] = _to_int(data["vel"])
	text[1] = "Position: " + str(data["pos"])
	text[2] = "Velocity: " + str(data["vel"])
	label.text = text.join("\n")

func _to_int(V:Vector2):
	var x:int = int(V.x)
	var y:int = int(V.y)
	return Vector2(x, y)

func user_inputs():
	if Input.is_action_just_pressed("ui_accept"):
		var boid = flock.get_child(active_boid)
		boid.in_control = ! boid.in_control
		text[3] = ("Controlling: " + str(boid.in_control))
	
	if Input.is_action_just_pressed("switch_boid"):
		var boid = flock.get_child(active_boid)
		boid.remove_child(cam)
		boid.active = false
		active_boid = (active_boid + 1) % flock.get_child_count()
		boid = flock.get_child(active_boid)
		boid.add_child(cam)
		boid.active = true
		text[0] = "Active boid: " + str(active_boid + 1) + "/" + str(flock.get_child_count())


func _on_Flock_boid_added():
	text[0] = "Active boid: " + str(active_boid + 1) + "/" + str(flock.get_child_count())
