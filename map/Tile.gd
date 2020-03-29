tool
extends Node2D

export (int) var size = 200 setget set_size

var coordinates = Vector3(0.0, 0.0, 0.0) setget set_coordinates

func _ready():
	set_size(size)
	$Area2D.connect("mouse_entered", self, "on_hover")
	$Area2D.connect("mouse_exited", self, "on_exit")

func set_size(value):
	size = value
	var points: PoolVector2Array = []
	for index in range(0, 6):
		var angle_deg = 60 * index - 30
		var angle_rad = PI / 180 * angle_deg
		points.append(Vector2(size*cos(angle_rad), size*sin(angle_rad)))
	
	if has_node("Shape"):
		$Shape.polygon = points
		$Area2D/CollisionPolygon2D.polygon = points


func set_coordinates(value):
	coordinates = value
	self.position.x = (sqrt(3.0)*coordinates.x + coordinates.z*sqrt(3.0)/2.0)*size*1.05
	self.position.y = (1.5 * coordinates.z)*size*1.05
	$Label.text = str(coordinates.x) + '.' + str(coordinates.y) + '.' + str(coordinates.z)

func on_hover():
	$Shape.color = Color(0.6, 0.0, 0.0)

func on_exit():
	$Shape.color = Color(0.91, 0.91, 0.52)
