extends Node2D

var hook = preload("res://Scenes/Hook.tscn") 

var ropeLength = 100
var  particlesPosition:  PoolVector2Array = PoolVector2Array()
var  oldParticlesPosition: PoolVector2Array = PoolVector2Array()
var	 accumulatedForces : PoolVector2Array = PoolVector2Array()

var  segmentShapes = []

var gravity = Vector2(0, 98)

const numOfIterations = 8
const maxDistanceBetweenPoints = 1

const initialPosition = Vector2(0, 0)  

var firstPosition = initialPosition 

var colitions : StaticBody2D = null

var speed: Vector2 = Vector2.ZERO
var nextExpectedParabolicPosition = Vector2.ZERO
var time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	colitions = StaticBody2D.new() 
	self.add_child(colitions)
	particlesPosition.resize(ropeLength)
	oldParticlesPosition.resize(ropeLength)
	accumulatedForces.resize(ropeLength) 

	for i in range(ropeLength):
		particlesPosition[i] = Vector2(initialPosition)
		oldParticlesPosition[i] = Vector2(initialPosition)
		accumulatedForces[i] = gravity
		if(i < ropeLength - 1):
			var particleShape = SegmentShape2D.new()
			particleShape.a = particlesPosition[i]
			particleShape.b = particlesPosition[i + 1]
			var shape = CollisionShape2D.new()
			shape.set_shape(particleShape)
			segmentShapes.append(particleShape)
			colitions.add_child(shape)
func _physics_process(delta): 
	calculateParabolicMovement(delta)
	accumulateForces()
	verlet(delta)
	satisfyConstraints()

func accumulateForces():
	for i in range(ropeLength):
		accumulatedForces[i] = gravity

func verlet(delta) : 
	for i in range(ropeLength) :
		var position = particlesPosition[i]
		var oldPosition = oldParticlesPosition[i]
		
		var acceleration = Vector2.ZERO
		var newPosition = position + (position - oldPosition + acceleration * delta * delta)

		particlesPosition[i] = newPosition
		oldParticlesPosition[i] = position

func satisfyConstraints():
	var space = get_world_2d().direct_space_state

	for _iteration in range(numOfIterations):
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

			#check rope colisions
			var collisions = space.intersect_point(newX1)
			if (collisions.size() > 0):
				var correction = newX1 - oldParticlesPosition[i]
				newX1 = x1 - correction * 2 #BOUNCE! 

			particlesPosition[i] = newX1
			particlesPosition[i + 1] = newX2

			segmentShapes[i].a = newX1
			segmentShapes[i].b = newX2

		particlesPosition[0] = firstPosition
		segmentShapes[0].a = firstPosition
	
		if (abs(particlesPosition[-1].distance_to(particlesPosition[-2])) < maxDistanceBetweenPoints):
			particlesPosition[-1] = nextExpectedParabolicPosition 
			segmentShapes[-2].b = nextExpectedParabolicPosition
		pass


func _draw():
	for i in range(ropeLength):
		if (i == ropeLength - 1):
			continue
		
		draw_line(particlesPosition[i], particlesPosition[i + 1], Color8(100,25, 100),  3, true) 
	
		#draw_circle(particlesPosition[i], 2, Color8(140, 0, 140))
		
func _process(_delta):
	update()

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton && event.is_pressed():  
			firstPosition = event.position 

func calculateParabolicMovement (delta):
	time += delta
	var x = speed.x * time 
	var y = (speed.y * time) + (gravity.y * time * time)/2

	speed.y = gravity.y * time

	nextExpectedParabolicPosition = Vector2(x, y) 

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
