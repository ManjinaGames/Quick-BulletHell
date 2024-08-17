extends Node2D
class_name Player
#-------------------------------------------------------------------------------
@export var hitBox: PlayerCollision
@export var graze: PlayerCollision
@export var magnet: PlayerCollision
#-------------------------------------------------------------------------------
const normalSpeed: float = 7.0
const focusSpeed: float = 3.5
#-------------------------------------------------------------------------------
var maxLives: int = 8
var maxPower: int = 4
#-------------------------------------------------------------------------------
