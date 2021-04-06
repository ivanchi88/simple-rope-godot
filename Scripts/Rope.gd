extends Node2D

var ropeLength = 101

var  particlesPosition:  PoolVector2Array = PoolVector2Array()
var  oldParticlesPosition: PoolVector2Array = PoolVector2Array()
var	 accumulatedForces : PoolVector2Array = PoolVector2Array()

var gravity = Vector2(0, 98)

const numOfIterations = 8
const maxDistanceBetweenPoints = 5

const initialPosition = Vector2(200, 50)  

var firstPosition = initialPosition
var secondPosition = null 

# Called when the node enters the scene tree for the first time.
func _ready():
	particlesPosition.resize(ropeLength)
	oldParticlesPosition.resize(ropeLength)
	accumulatedForces.resize(ropeLength)

	for i in range(ropeLength):
		particlesPosition[i] = Vector2(initialPosition.x + i + 2, initialPosition.y)
		oldParticlesPosition[i] = Vector2(initialPosition.x + i + 2, initialPosition.y)
		accumulatedForces[i] = gravity

func _physics_process(delta): 
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
		
		var acceleration = accumulatedForces[i]
		var newPosition = position + (position - oldPosition + acceleration * delta * delta)

		particlesPosition[i] = newPosition
		oldParticlesPosition[i] = position

func satisfyConstraints():
	for _iteration in range(numOfIterations):
		for i in range(ropeLength):
			if(i == ropeLength - 1):
				continue
			
			var x1 = particlesPosition[i]
			var x2 = particlesPosition[i + 1]

			var distance = x2 - x1
			var aaay: float = sqrt(distance.dot(distance)) + 0.000001
			var diff = (aaay - maxDistanceBetweenPoints) / aaay
			particlesPosition[i] = x1 + (distance * 0.5 * diff)
			particlesPosition[i + 1] = x2 - (distance * 0.5 * diff) 

		particlesPosition[0] = firstPosition
	
		if(secondPosition != null) :
			particlesPosition[-1] = secondPosition



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
		if(secondPosition == null) :
			secondPosition = event.position 
		else:
			firstPosition = event.position
			secondPosition = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
