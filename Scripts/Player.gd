extends KinematicBody2D

var speed = Vector2(0, 0) 
var rope = preload("res://Scenes/Rope.tscn") 
var hasRope = false 
var ropee = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	speed = move_and_slide(speed * 1000)
	speed = Vector2.ZERO



func _input(event):
	if(Input.is_key_pressed(KEY_A)):
		speed.x = -1
	if(Input.is_key_pressed(KEY_D)):
		speed.x = 1
		$sprite.flip_h = true
	if(Input.is_key_pressed(KEY_W)):
		speed.y = -1
	if (Input.is_key_pressed(KEY_S)):
		speed.y = 1
	
	speed = speed.normalized() 

	if (Input.is_key_pressed(KEY_SPACE)):
		var mouse = get_viewport().get_mouse_position()
		var ropeDir = (mouse - global_position).normalized()
		var ropeInstance = ropee
		if(ropeInstance == null):
			ropeInstance = rope.instance()
			ropee = ropeInstance

		ropeInstance.speed = ropeDir.normalized() * 10
		ropeInstance.position = global_position
		get_parent().add_child(ropeInstance)