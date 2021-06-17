extends Node2D

signal boid_added

export(int, 1, 10000) var flock_size:int = 10

var Boid = preload("res://Objects/Boid/Boid.tscn")

func _ready():
	var boid = Boid.instance()
	add_child(boid)
	boid.vel.x = int(rand_range(-50, 50))
	boid.vel.y = int(rand_range(-50, 50))
	
	if get_child_count() < flock_size: _populate()

func _populate():
	yield(get_tree(), "idle_frame")
	var boid = Boid.instance()
	add_child(boid)
	boid.vel.x = rand_range(-50, 50)
	boid.vel.y = rand_range(-50, 50)
	emit_signal("boid_added")
	if get_child_count() < flock_size:
		yield(_populate(), "completed")
	
	for boid in get_children():
		var flock = get_children()
		flock.erase(boid)
		for other in flock:
			boid._on_PerceptionArea_body_entered(other)

func _physics_process(_delta):
	for boid in get_children():
		boid.flock()
