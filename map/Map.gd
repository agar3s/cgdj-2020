extends Node2D

var Tile = preload("res://map/Tile.tscn")

export (int) var tile_size = 13
export (int) var radius = 13

export (int) var min_survive = 2 
export (int) var max_survive = 5

export (int) var min_born = 3
export (int) var max_born = 3

var map: Dictionary = {}
var playing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

	# sort layout
	var x = -5.0
	var y = -5.0
	var z = 0.0
	var index = 0
	
	$Play.connect("button_down", self, "toggle_play")
	$Timer.connect("timeout", self, "next_step")
	$Next.connect("button_down", self, "next_step")
	$Random.connect("button_down", self, "random_populate")
	$Clear.connect("button_down", self, "clear")
	$MinSurvive.value = min_survive
	$MaxSurvive.value = max_survive
	$MinBorn.value = min_born
	$MaxBorn.value = max_born

	for i in range(-radius, radius+1):
		var r1 = max(-radius, -i - radius)
		var r2 = min(radius, -i + radius)
		for z in range(r1, r2+1):
			y = -i - z
			var tile = Tile.instance()
			tile.size = tile_size
			tile.coordinates = Vector3(i, y, z)
			tile.connect("mouse_exited", self, "on_tile_exit", [tile])
			tile.connect("mouse_entered", self, "on_tile_hover", [tile])
			$Tiles.add_child(tile)
			map[tile.get_hash()] = tile

	# clean neighbors
	for tile in $Tiles.get_children():
		var subset = []
		for neighbor_hash in tile.neighbors:
			if map.has(neighbor_hash):
				subset.append(neighbor_hash)
		tile.neighbors = subset

	random_populate()
	print($Tiles.get_child_count())


func on_tile_hover(tile):
	for neighbor_hash in tile.neighbors:
		map[neighbor_hash].set_neighbor_hover(true)


func on_tile_exit(tile):
	for neighbor_hash in tile.neighbors:
		map[neighbor_hash].set_neighbor_hover(false)
	

func next_step():
	min_survive = $MinSurvive.value
	max_survive = $MaxSurvive.value
	min_born = $MinBorn.value
	max_born = $MaxBorn.value
	
	for tile in $Tiles.get_children():
		tile.alive_neighbors = 0
		for neighbor_hash in tile.neighbors:
			tile.alive_neighbors += map[neighbor_hash].live_factor if map[neighbor_hash].selected else 0

	for tile in $Tiles.get_children():
		tile.solve_next(min_survive, max_survive, min_born, max_born)


func random_populate():
	for tile in $Tiles.get_children():
		tile.selected = randf() > $RandomBox.value
		tile.live_factor = 1.0

func clear():
	for tile in $Tiles.get_children():
		tile.selected = false
		tile.live_factor = 1.0

func toggle_play():
	playing = !playing
	if playing:
		$Timer.start()
		$Play.text = 'Pause'
	else:
		$Timer.stop()
		$Play.text = 'Play'

