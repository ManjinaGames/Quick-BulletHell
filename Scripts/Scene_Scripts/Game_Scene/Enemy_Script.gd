extends StaticBody2D
class_name Enemy
#-------------------------------------------------------------------------------
enum ENEMY_STATE{ALIVE, DEATH}
#region VARIABLES
@export var label: Label
@export var myENEMY_STATE: ENEMY_STATE = ENEMY_STATE.ALIVE
#-------------------------------------------------------------------------------
var vel: float
var dir: float
var velX: float
var velY: float
#-------------------------------------------------------------------------------
var hp: int
var maxHp: int
var canBeHit: bool = true
#endregion
#-------------------------------------------------------------------------------
