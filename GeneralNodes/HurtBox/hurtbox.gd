class_name HurtBox extends Area2D

@export var damage := 1

func _ready() -> void:
  area_entered.connect(AreaEntered)
  pass

func AreaEntered(area: Area2D) -> void:
  if area is HitBox:
    area.TakeDamage(self)
  pass