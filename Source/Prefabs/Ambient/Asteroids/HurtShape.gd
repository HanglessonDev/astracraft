## One hurt shape with its local offset: shape and place travel together.
class_name HurtShape
extends Resource

## The collision shape (any Shape2D: circle, rectangle, convex...).
@export var shape: Shape2D
## Local offset inside the HurtArea2D (tune per asteroid silhouette).
@export var offset := Vector2.ZERO

