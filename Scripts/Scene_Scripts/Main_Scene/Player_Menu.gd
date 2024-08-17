extends Control
class_name Player_Menu
#region VARIABLES
@export var mainScene: Main_Scene
var gameVariables: Game_Variables
#-------------------------------------------------------------------------------
@export var button: Array[Button]
@export var back: Button
#endregion
#-------------------------------------------------------------------------------
#region STATE MACHINE
func Start() -> void:
	gameVariables = get_node("/root/GameVariables")
	#-------------------------------------------------------------------------------
	SetAllButtons()
	hide()
#endregion
#-------------------------------------------------------------------------------
#region BUTTON FUNCTIONS
func SetAllButtons() -> void:
	for _i in 2:
		gameVariables.SetButton(button[_i], gameVariables.CommonSelected, func():PlayerButton_Subited(_i), AnyButton_Canceled)
	gameVariables.SetButton(back, gameVariables.CommonSelected, BackButton_Subited, BackButton_Canceled)
#-------------------------------------------------------------------------------
func PlayerButton_Subited(_i:int) -> void:
	gameVariables.currentSaveData.playerIndex = _i
	mainScene.mainMenu.SetGameInfo()
	gameVariables.Save_SaveData(gameVariables.currentSaveData, gameVariables.optionMenu.optionSaveData.saveIndex)
	BackButton_Common()
	gameVariables.CommonSubmited()
#-------------------------------------------------------------------------------
func AnyButton_Canceled(_event:InputEvent) -> void:
	if(_event.is_action_pressed(gameVariables.cancelInput)):
		gameVariables.MoveToButton(back)
		gameVariables.CommonCanceled()
#-------------------------------------------------------------------------------
func BackButton_Subited() -> void:
	BackButton_Common()
	gameVariables.CommonSubmited()
#-------------------------------------------------------------------------------
func BackButton_Canceled(_event:InputEvent) -> void:
	if(_event.is_action_pressed(gameVariables.cancelInput)):
		BackButton_Common()
		gameVariables.CommonCanceled()
#-------------------------------------------------------------------------------
func BackButton_Common() -> void:
	hide()
	gameVariables.MoveToButton(mainScene.mainMenu.button[1])
	mainScene.mainMenu.show()
#endregion
#-------------------------------------------------------------------------------
func SetIdiome():
	back.text = tr("optionMenu_back")
	for _i in button.size():
		button[_i].text = tr("playerMenu_button"+str(_i))
#-------------------------------------------------------------------------------
