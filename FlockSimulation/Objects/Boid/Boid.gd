extends KinematicBody2D

onready var sprite:Sprite = $Sprite

export(float) var max_separation_force:float = 0.8
export(float) var max_alignment_force:float = 0.8
export(float) var max_cohesion_force:float = 0.8
export(float) var max_speed:float = 50

var active:bool = false setget set_active
var in_control:bool = false setget set_in_control

var vel:Vector2 = Vector2.ZERO
var acc:Vector2 = Vector2.ZERO

var perceived:Array = []
var too_closed:Array = []

func _physics_process(_delta):
	if in_control:
		var dir:Vector2 = Vector2.ZERO
		if Input.is_action_pressed("move_down"):
			dir.y = 1
		elif Input.is_action_pressed("move_up"):
			dir.y = -1
		if Input.is_action_pressed("move_left"):
			dir.x = -1
		elif Input.is_action_pressed("move_right"):
			dir.x = 1
		
		vel += (dir * max_speed).clamped(1)
		vel = vel.clamped(max_speed)
		var _ms = move_and_slide(vel)
		rotation = vel.angle()

func flock():
	if in_control: return
	if vel or acc:
		rotation = vel.angle()
		flock_calc()
		vel += acc
		vel = vel.clamped(max_speed)
		# TO-DO: figure out how this really works
		var _ms = move_and_slide(vel)
		acc = Vector2.ZERO

# steering = desired velocity - current velocity

func flock_calc():
	var separation = separation_force()
	var alignment  = alignment_force()
	var cohesion   = cohesion_force()
	acc += separation
	acc += alignment
	acc += cohesion

func separation_force():
	var F:Vector2 = Vector2.ZERO
	if too_closed:
		for boid in too_closed:
			var f = position.direction_to(boid.position)
			f *= -1
			F += f
		F /= too_closed.size() # Average
		F = F * max_speed # Desired velocity
		F = F - vel # Steering
		F = F.clamped(max_separation_force)
	return F

func alignment_force():
	var F:Vector2 = Vector2.ZERO
	if perceived:
		for boid in perceived:
			F += boid.vel
		F /= perceived.size()
		F = F.normalized() * max_speed
		F = F - vel
		F = F.clamped(max_alignment_force)
	return F

func cohesion_force():
	var F:Vector2 = Vector2.ZERO
	if perceived:
		for boid in perceived:
			F += boid.position
		F /= perceived.size()
		F = position.direction_to(F)
		F = F * max_speed
		F = F - vel
		F = F.clamped(max_cohesion_force)
	return F

func boid_data():
	return {
		"pos": Vector2(position.x, position.y),
		"vel": Vector2(vel.x, vel.y),
		"ind": get_index()
	}

func set_active(val:bool):
	active = val
	if not active:
		in_control = false
		sprite.frame = 0
	else:
		sprite.frame = 1

func set_in_control(val:bool):
	if not active:
		in_control = false
	else:
		in_control = val

func _on_PerceptionArea_body_entered(body):
	if body.has_method("boid_data") and ! perceived.has(body):
		perceived.append(body)

func _on_PerceptionArea_body_exited(body):
	if body.has_method("boid_data") and perceived.has(body):
		perceived.erase(body)

func _on_SeparationArea_body_entered(body):
	if body.has_method("boid_data") and ! too_closed.has(body):
		too_closed.append(body)

func _on_SeparationArea_body_exited(body):
	if body.has_method("boid_data") and too_closed.has(body):
		too_closed.erase(body)
