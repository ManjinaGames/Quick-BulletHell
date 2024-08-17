extends Control
class_name Title_Scene
#region VARIABLES
var gameVariables: Game_Variables
#-------------------------------------------------------------------------------
@export var titleMenu: Title_Menu
@export var saveMenu: Save_Menu
@export var saveMenu2: Save_Menu2
#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
#region STATE MACHINE
func _ready() -> void:
	gameVariables = get_node("/root/GameVariables")
	#-------------------------------------------------------------------------------
	titleMenu.Start()
	saveMenu.Start()
	saveMenu2.Start()
	#-------------------------------------------------------------------------------
	SetIdiome()
	#-------------------------------------------------------------------------------
	gameVariables.MoveToButton(titleMenu.button[0])
	gameVariables.PlayBGM(gameVariables.bgmTitle)
	show()
#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
func SetIdiome():
	gameVariables.DisconnectAll(gameVariables.optionMenu.idiomeChange)
	#-------------------------------------------------------------------------------
	gameVariables.optionMenu.idiomeChange.connect(titleMenu.SetIdiome)
	gameVariables.optionMenu.idiomeChange.connect(saveMenu.SetIdiome)
	gameVariables.optionMenu.idiomeChange.connect(saveMenu2.SetIdiome)
	#-------------------------------------------------------------------------------
	titleMenu.SetIdiome()
	saveMenu.SetIdiome()
	saveMenu2.SetIdiome()
