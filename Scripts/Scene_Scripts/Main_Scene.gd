extends Control
class_name Main_Scene
#region VARIABLES
var singleton: Singleton
#-------------------------------------------------------------------------------
@export var mainMenu: Main_Menu
@export var difficultyMenu: Difficulty_Menu
@export var playerMenu: Player_Menu
@export var stageMenu: Stage_Menu
@export var startMenu: Start_Menu
#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
#region MONOBEHAVIOUR
func _ready() -> void:
	singleton = get_node("/root/singleton")
	#-------------------------------------------------------------------------------
	mainMenu.Start()
	difficultyMenu.Start()
	playerMenu.Start()
	stageMenu.Start()
	startMenu.Start()
	#-------------------------------------------------------------------------------
	SetIdiome()
	#-------------------------------------------------------------------------------
	singleton.MoveToButton(mainMenu.button[0])
	show()
#endregion
#-------------------------------------------------------------------------------
#region IDIOME FUNCTIONS
func SetIdiome():
	singleton.DisconnectAll(singleton.optionMenu.idiomeChange)
	#-------------------------------------------------------------------------------
	singleton.optionMenu.idiomeChange.connect(mainMenu.SetIdiome)
	singleton.optionMenu.idiomeChange.connect(playerMenu.SetIdiome)
	singleton.optionMenu.idiomeChange.connect(difficultyMenu.SetIdiome)
	singleton.optionMenu.idiomeChange.connect(stageMenu.SetIdiome)
	singleton.optionMenu.idiomeChange.connect(startMenu.SetIdiome)
	#-------------------------------------------------------------------------------
	mainMenu.SetIdiome()
	playerMenu.SetIdiome()
	difficultyMenu.SetIdiome()
	stageMenu.SetIdiome()
	startMenu.SetIdiome()
#endregion
#-------------------------------------------------------------------------------
