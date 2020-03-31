extends Node2D

signal mouse_entered
signal mouse_exited

export (int) var size = 100 setget set_size
export (float) var stroke = 0.05


export (Color) var outline_color = Color(0.99, 0.22, 0.2)
export (Color) var outline_hover_color = Color(0.11, 0.95, 1.00)
export (Color) var base_color = Color(0.03, 0.03, 0.09)
export (Color) var selected_color = Color(0.8, 0.76, 0.8)

var current_color = base_color

var coordinates = Vector3(0.0, 0.0, 0.0) setget set_coordinates

var selected = false setget set_selected
var neighbor_hover = false setget set_neighbor_hover

var neighbors = []
var alive_neighbors = 0

var live_factor = 1.0

func _ready():
	set_size(size)
	$Area2D.connect("mouse_entered", self, "on_hover")
	$Area2D.connect("mouse_exited", self, "on_exit")
	$Area2D.connect("input_event", self, "on_input")
	$Back.color = outline_color
	$Shape.color = base_color

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
	set_neighbor_coordinates()

func set_neighbor_coordinates():
	neighbors = [
		hash(Vector3(coordinates.x + 1, coordinates.y + 0, coordinates.z - 1)),
		hash(Vector3(coordinates.x + 1, coordinates.y - 1, coordinates.z + 0)),
		hash(Vector3(coordinates.x + 0, coordinates.y - 1, coordinates.z + 1)),
		hash(Vector3(coordinates.x - 1, coordinates.y + 0, coordinates.z + 1)),
		hash(Vector3(coordinates.x - 1, coordinates.y + 1, coordinates.z + 0)),
		hash(Vector3(coordinates.x + 0, coordinates.y + 1, coordinates.z - 1))
	]

func get_hash():
	return hash(coordinates)

func on_hover():
	$Back.color = outline_hover_color
	z_index = 25
	yield(get_tree().create_timer(0.01), 'timeout')
	emit_signal("mouse_entered")

func on_exit():
	$Back.color = outline_color
	z_index = 0
	emit_signal("mouse_exited")

func set_neighbor_hover(value):
	neighbor_hover = value
	if neighbor_hover:
		$Shape.color += Color(0.1, 0.1, 0.1)
	else:
		$Shape.color = current_color

	
func set_selected(value):
	selected = value
	if selected:
		current_color = selected_color
	else:
		current_color = base_color
	$Shape.color = current_color


func on_input(_node, _event, _shape):
	if _event is InputEventMouseButton and _event.pressed:
		self.selected = !selected


func solve_next(min_survive, max_survive, min_born, max_born):
	if selected:
		self.selected =  alive_neighbors >= min_survive && alive_neighbors <= max_survive
		#if alive_neighbors == min_survive:
		#	live_factor += 0.1
		#elif alive_neighbors == max_survive:
		#	live_factor -= 0.1
	elif alive_neighbors >= min_born && alive_neighbors <= max_born:
		self.selected = true
		live_factor = 1.0
	
	$Label.text = str(live_factor)



