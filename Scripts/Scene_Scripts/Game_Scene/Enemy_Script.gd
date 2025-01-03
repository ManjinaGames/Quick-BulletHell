extends Object2D
class_name Enemy
#region VARIABLES
@export var label: Label
@export var area2D: StaticBody2D
@export var collider: CollisionShape2D
#-------------------------------------------------------------------------------
signal _deathSignal
#-------------------------------------------------------------------------------
var myOBJECT2D_STATE: OBJECT2D_STATE
#-------------------------------------------------------------------------------
var hp: int
var maxHp: int
var canBeHit: bool = true
#endregion
#-------------------------------------------------------------------------------
