extends Node

var currentTypeMapBounds: Array[Vector2]
signal TileMapBoundsChange(bounds: Array[Vector2])

func change_tilemap_bounds(bounds: Array[Vector2]) -> void:
  currentTypeMapBounds = bounds
  TileMapBoundsChange.emit(bounds)