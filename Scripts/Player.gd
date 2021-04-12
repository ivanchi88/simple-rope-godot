extends KinematicBody2D

export (int) var speed = 800
export (int) var jump_speed = -900
export (int) var gravity = 4000 
var velocity = Vector2.ZERO

var rope = preload("res://Scenes/Rope.tscn") 
var hasRope = false 
var ropee = null

var cooldown = 10
var passed = cooldown

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	
	
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)

	passed += delta

	if(ropee != null):
		ropee.firstPosition = position


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
		var ropeInstance = ropee 
		if(ropeInstance == null):
			ropeInstance = rope.instance()
			ropee = ropeInstance

		ropeInstance.accel = ropeDir.normalized() * 4000
		ropee.firstPosition = position

		get_parent().add_child(ropeInstance)

		passed = 0
