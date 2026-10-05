class_name  GameResource
extends Node


signal max_changed(new_value: int)
signal current_changed(new_value: int)
signal depleted
signal replenished


##
@export var max_amount := 10 : set = set_max_amount

##
@export var current_amount := 1 : set = set_current_amount


##
func set_max_amount(new_max_amount: int) -> void:
	max_amount = new_max_amount
	if max_amount < current_amount:
		current_amount = new_max_amount
	max_changed.emit(max_amount)

##
func set_current_amount(new_current_amount: int) -> void:
	current_amount = clampi(new_current_amount, 0 , max_amount)
	current_changed.emit(current_amount)
	
	if current_amount < 1:
		depleted.emit()

	if current_amount >= max_amount:
		replenished.emit()

##
func increase(amount: int) -> void:
	current_amount += amount

##
func decrease(amount: int) -> void:
	current_amount -= amount

##
func deplete() -> void:
	current_amount = 0

##
func replenish() -> void:
	current_amount = max_amount
	
