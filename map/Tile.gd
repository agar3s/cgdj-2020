extends Node2D

export (int) var size = 100 setget set_size
export (float) var stroke = 0.05

var coordinates = Vector3(0.0, 0.0, 0.0) setget set_coordinates

var selected = false

func _ready():
	set_size(size)
	$Area2D.connect("mouse_entered", self, "on_hover")
	$Area2D.connect("mouse_exited", self, "on_exit")
	$Area2D.connect("input_event", self, "on_input")

func set_size(value):
	size = value
	var points: PoolVector2Array = []
	
	var pointsBack: PoolVector2Array = []
	
	for index in range(0, 6):
		var angle_deg = 60 * index - 30
		var angle_rad = PI / 180 * angle_deg
		points.append(Vector2(size*cos(angle_rad), size*sin(angle_rad)))
		pointsBack.append(Vector2(size*1.1*cos(angle_rad), size*(1.0+stroke*2)*sin(angle_rad)))
	
	if has_node("Shape"):
		$Shape.polygon = points
		$Back.polygon = pointsBack
		$Area2D/CollisionPolygon2D.polygon = points


func set_coordinates(value):
	coordinates = value
	self.position.x = (sqrt(3.0)*coordinates.x + coordinates.z*sqrt(3.0)/2.0)*size*(1.0+stroke)
	self.position.y = (1.5 * coordinates.z)*size*(1.0+stroke)
	$Label.text = str(coordinates.x) + '.' + str(coordinates.y) + '.' + str(coordinates.z)

func on_hover():
	$Back.color.a = 1.0
	z_index = 25

func on_exit():
	$Back.color.a = 0.0
	z_index = 0

func on_input(node, event, shape):
	if event is InputEventMouseButton and event.pressed:
		if selected:
			$Shape.color = Color(0.91, 0.92, 0.52)
		else:
			$Shape.color = Color(0.2, 0.8, 0.7)
		selected = !selected
