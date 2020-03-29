tool
extends Node2D

var Tile = preload("res://map/Tile.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	var x = -5.0
	var y = -5.0
	var z = 0.0
	var index = 0
	var radius = 3

	for i in range(-radius, radius+1):
		var r1 = max(-radius, -i - radius)
		var r2 = min(radius, -i + radius)
		for z in range(r1, r2+1):
			y = -i - z
			var tile = Tile.instance()
			tile.size = 40
			tile.coordinates = Vector3(i, y, z)
			$Tiles.add_child(tile)

