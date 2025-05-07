class_name HitBox extends Area2D

signal damage(hurt_box: HurtBox)

func TakeDamage(hurtbox: HurtBox) -> void:
  damage.emit(hurtbox)
