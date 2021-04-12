extends KinematicBody2D

export (int) var speed = 800
export (int) var jump_speed = -900
export (int) var gravity = 4000 
var velocity = Vector2.ZERO

var ropeScene = preload("res://Scenes/Rope.tscn") 
var hasRope = false 
var rope = null

var cooldown = 10
var passed = cooldown

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):

	if(rope != null):
		if (rope.ropeLimit && rope.hooked):
			if (rope.lastPosition().x - ( global_position.x + velocity.x) < 0):
				velocity.x = 0 if velocity.x > 0 else velocity.x
			else:
				velocity.x = 0 if velocity.x <= 0 else velocity.x
		
		rope.firstPosition = global_position
	
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)

	passed += delta 


func _input(event):
	velocity.x = 0
	if(Input.is_key_pressed(KEY_A)):
		velocity.x -= speed
		$sprite.flip_h = true
	if(Input.is_key_pressed(KEY_D)):
		velocity.x += speed
		$sprite.flip_h = false
	if(Input.is_key_pressed(KEY_W)): 
		if is_on_floor():
			velocity.y = jump_speed
	
	
	speed = speed 

	if (cooldown < passed && Input.is_mouse_button_pressed(BUTTON_LEFT)):
		var mouse = get_viewport().get_mouse_position()
		var ropeDir = (mouse - global_position).normalized()
		var ropeInstance = rope 
		if(ropeInstance == null):
			ropeInstance = ropeScene.instance()
			rope = ropeInstance

		ropeInstance.accel = ropeDir.normalized() * 4000
		rope.firstPosition = global_position
		rope.hooked = false

		get_parent().add_child(ropeInstance)

		passed = 0
