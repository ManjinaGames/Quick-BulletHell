extends Control
class_name Main_Scene
#region VARIABLES
var gameVariables: Game_Variables
#-------------------------------------------------------------------------------
@export var mainMenu: Main_Menu
@export var difficultyMenu: Difficulty_Menu
@export var playerMenu: Player_Menu
@export var stageMenu: Stage_Menu
@export var startMenu: Start_Menu
#endregion
#-------------------------------------------------------------------------------
#region MONOBEHAVIOUR
func _ready() -> void:
	gameVariables = get_node("/root/GameVariables")
	#-------------------------------------------------------------------------------
	mainMenu.Start()
	difficultyMenu.Start()
	playerMenu.Start()
	stageMenu.Start()
	startMenu.Start()
	#-------------------------------------------------------------------------------
	SetIdiome()
	#-------------------------------------------------------------------------------
	gameVariables.MoveToButton(mainMenu.button[0])
	show()
#endregion
#-------------------------------------------------------------------------------
#region IDIOME FUNCTIONS
func SetIdiome():
	gameVariables.DisconnectAll(gameVariables.optionMenu.idiomeChange)
	#-------------------------------------------------------------------------------
	gameVariables.optionMenu.idiomeChange.connect(mainMenu.SetIdiome)
	gameVariables.optionMenu.idiomeChange.connect(playerMenu.SetIdiome)
	gameVariables.optionMenu.idiomeChange.connect(difficultyMenu.SetIdiome)
	gameVariables.optionMenu.idiomeChange.connect(stageMenu.SetIdiome)
	gameVariables.optionMenu.idiomeChange.connect(startMenu.SetIdiome)
	#-------------------------------------------------------------------------------
	mainMenu.SetIdiome()
	playerMenu.SetIdiome()
	difficultyMenu.SetIdiome()
	stageMenu.SetIdiome()
	startMenu.SetIdiome()
#endregion
#-------------------------------------------------------------------------------
