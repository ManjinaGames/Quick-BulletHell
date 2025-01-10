extends Object2D
class_name Player
#-------------------------------------------------------------------------------
enum PLAYER_STATE{ALIVE, DEATH, INVINCIBLE}
#region VARIABLES
@export var myPLAYER_STATE: PLAYER_STATE
@export var hitBox: PlayerCollision
@export var graze: PlayerCollision
@export var magnet: PlayerCollision
#-------------------------------------------------------------------------------
const normalSpeed: float = 7.0
const focusSpeed: float = 3.5
#-------------------------------------------------------------------------------
var maxLives: int = 80
var maxPower: int = 40
#endregion
#-------------------------------------------------------------------------------
