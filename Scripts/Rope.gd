extends Node2D

var hookScene = preload("res://Scenes/Hook.tscn") 

var ropeLength = 50
const numOfIterations = 8
const maxDistanceBetweenPoints = 5

var  particlesPosition:  PoolVector2Array = PoolVector2Array()
var  oldParticlesPosition: PoolVector2Array = PoolVector2Array()
var	 accumulatedForces : PoolVector2Array = PoolVector2Array()

var gravity = Vector2(0, 98)
 
var firstPosition
func lastPosition() :
	return particlesPosition[-1]

var accel: Vector2 = Vector2.ZERO
var drag: float = 0.9

var hookable_layer = 16

var hook
var hookedPos = Vector2.ZERO
var hooked = false
var ropeLimit = false

# Called when the node enters the scene tree for the first time.
func _ready():

	particlesPosition.resize(ropeLength)
	oldParticlesPosition.resize(ropeLength)
	accumulatedForces.resize(ropeLength) 

	hook = hookScene.instance()
	add_child(hook)

	for i in range(ropeLength):
		particlesPosition[i] = Vector2(firstPosition)
		oldParticlesPosition[i] = Vector2(firstPosition)
		accumulatedForces[i] = gravity + accel

func _physics_process(delta): 

	calculateAcceleration(delta)

	accumulateForces()
	verlet(delta)
	satisfyConstraints()

	moveHook()

func accumulateForces():
	for i in range(ropeLength):
		accumulatedForces[i] = gravity + accel

func verlet(delta) : 
	for i in range(ropeLength) :
		var position = particlesPosition[i]
		var oldPosition = oldParticlesPosition[i]
		
		var acceleration = accumulatedForces[i]
		var newPosition = position + (position - oldPosition + acceleration * delta * delta)

		particlesPosition[i] = newPosition
		oldParticlesPosition[i] = position

func satisfyConstraints():
	var space = get_world_2d().direct_space_state

	var ropeSize = 0

	for _iteration in range(numOfIterations):
		hooked = hookedPos != Vector2.ZERO || false
		ropeSize = 0
		ropeLimit = false
		for i in range(ropeLength):
			if(i == ropeLength - 1):
				continue
			
			#check rope lenght
			var x1 = particlesPosition[i]
			var x2 = particlesPosition[i + 1]

			var distance = x2 - x1

			var delt: float = sqrt(distance.dot(distance)) + 0.000001
			var diff = (delt - maxDistanceBetweenPoints) / delt

			var newX1 = x1 + (distance * 0.5 * diff)
			var newX2 =  x2 - (distance * 0.5 * diff) 

			#check rope colisions with global colision
			var collisions = space.intersect_point(global_position + newX1, 32, [], hookable_layer)
			if (collisions.size() > 0):
				var correction = newX1 - oldParticlesPosition[i]
				newX1 = x1 - correction * 2 #BOUNCE! 
				if(i == ropeLength - 1):
					hooked = true

			particlesPosition[i] = newX1
			particlesPosition[i + 1] = newX2  
			ropeSize += newX1.distance_to(newX2) 

		particlesPosition[0] = firstPosition 
		
		if (space.intersect_point(global_position + particlesPosition[-1], 32, [], hookable_layer).size() > 0):
			hooked = true
			hookedPos = particlesPosition[-1]

		if(hooked):
			particlesPosition[-1] = hookedPos 

	if(ropeSize <= abs(particlesPosition[0].distance_to(particlesPosition[-1]))):
		firstPosition = particlesPosition[0]
		ropeLimit = true
	
			
func _draw():
	for i in range(ropeLength):
		if (i == ropeLength - 1):
			continue
		
		draw_line(particlesPosition[i], particlesPosition[i + 1], Color8(100,25, 100),  3, true) 
	
		#draw_circle(particlesPosition[i], 2, Color8(140, 0, 140))

func moveHook():
	if(hook != null && !hooked):
		hook.position = hookedPos
		hook.rotation = (gravity + accel).angle() + PI/2
		
func _process(_delta):
	update()

func _input(event):
	# Mouse in viewport coordinates.
	pass

func calculateAcceleration(delta): 
	accel = accel * (drag - delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
