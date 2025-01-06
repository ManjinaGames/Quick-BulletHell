extends Object2D
class_name Bullet
#region VARIABLES
var myOBJECT2D_STATE: OBJECT2D_STATE
#-------------------------------------------------------------------------------
var size: Vector2 = Vector2(2.0, 4.0)
#endregion
#-------------------------------------------------------------------------------
#region FUNCTIONS
func _draw():
	draw_rect(Rect2(-size.x, -size.y, size.x*2.0, size.y*2.0), Color.RED)
#endregion
#-------------------------------------------------------------------------------
