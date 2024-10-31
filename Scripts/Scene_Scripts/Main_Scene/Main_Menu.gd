extends Control
class_name Main_Menu
#region VARIABLES
@export var mainScene: Main_Scene
var gameVariables: Game_Variables
#-------------------------------------------------------------------------------
@export var title: Label
@export var button: Array[Button]
@export var gameInfo: Label
#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
#region STATE MACHINE
func Start() -> void:
	gameVariables = get_node("/root/GameVariables")
	#-------------------------------------------------------------------------------
	gameVariables.SetButton(button[0], gameVariables.CommonSelected, StartButton_Subited, AnyButton_Canceled)
	gameVariables.SetButton(button[1], gameVariables.CommonSelected, PlayerButton_Submited, AnyButton_Canceled)
	gameVariables.SetButton(button[2], gameVariables.CommonSelected, DifficultyButton_Submited, AnyButton_Canceled)
	gameVariables.SetButton(button[3], gameVariables.CommonSelected, OptionsButton_Subited, AnyButton_Canceled)
	gameVariables.SetButton(button[4], gameVariables.CommonSelected, QuitButton_Subited, AnyButton_Canceled)
	#-------------------------------------------------------------------------------
	OptionMenu_BackButton_Set()
	#-------------------------------------------------------------------------------
	show()
#endregion
#-------------------------------------------------------------------------------
#region BUTTON FUNCTIONS
func StartButton_Subited() -> void:
	hide()
	mainScene.stageMenu.UpdateStageButtons()
	mainScene.stageMenu.show()
	gameVariables.MoveToButton(mainScene.stageMenu.button[0])
	gameVariables.CommonSubmited()
#-------------------------------------------------------------------------------
func PlayerButton_Submited() -> void:
	hide()
	mainScene.playerMenu.show()
	gameVariables.MoveToButton(mainScene.playerMenu.button[gameVariables.currentSaveData_Json["playerIndex"]])
	gameVariables.CommonSubmited()
#-------------------------------------------------------------------------------
func DifficultyButton_Submited() -> void:
	hide()
	mainScene.difficultyMenu.show()
	gameVariables.MoveToButton(mainScene.difficultyMenu.button[gameVariables.currentSaveData_Json["difficultyIndex"]])
	gameVariables.CommonSubmited()
#-------------------------------------------------------------------------------
func OptionsButton_Subited() -> void:
	mainScene.mainMenu.hide()
	mainScene.hide()
	gameVariables.MoveToButton(gameVariables.optionMenu.back)
	gameVariables.optionMenu.show()
	gameVariables.CommonSubmited()
#-------------------------------------------------------------------------------
func QuitButton_Subited() -> void:
	gameVariables.CommonSubmited()
	gameVariables.currentSaveData_Json = {}
	get_tree().change_scene_to_file(gameVariables.titleScene_Path)
#-------------------------------------------------------------------------------
func AnyButton_Canceled() -> void:
	gameVariables.MoveToLastButton(button)
	gameVariables.CommonCanceled()
#endregion
#-------------------------------------------------------------------------------
#region OPTION MENU BACK BUTTON
func OptionMenu_BackButton_Set() -> void:
	gameVariables.DisconnectButton(gameVariables.optionMenu.back)
	gameVariables.SetButton(gameVariables.optionMenu.back,  gameVariables.CommonSelected, OptionMenu_BackButton_Subited, OptionMenu_BackButton_Canceled)
#-------------------------------------------------------------------------------
func OptionMenu_BackButton_Subited() -> void:
	OptionMenu_BackButton_Common()
	gameVariables.CommonSubmited()
#-------------------------------------------------------------------------------
func OptionMenu_BackButton_Canceled() -> void:
	OptionMenu_BackButton_Common()
	gameVariables.CommonCanceled()
#-------------------------------------------------------------------------------
func OptionMenu_BackButton_Common() -> void:
	gameVariables.optionMenu.Save_OptionSaveData_Json()
	gameVariables.optionMenu.hide()
	mainScene.mainMenu.show()
	mainScene.show()
	gameVariables.MoveToButton(button[3])
#endregion
#-------------------------------------------------------------------------------
#region IDIOME FUNCTIONS
func SetIdiome():
	SetGameInfo()
	for _i in button.size():
		button[_i].text = tr("mainMenu_button"+str(_i))
#-------------------------------------------------------------------------------
func SetGameInfo():
	var _saveData: Dictionary = gameVariables.currentSaveData_Json
	var _playerIndex: StringName = str(_saveData["playerIndex"])
	var _difficultyIndex: StringName = str(_saveData["difficultyIndex"])
	var _stageIndex: StringName = str(_saveData["stageIndex"])
	#-------------------------------------------------------------------------------
	gameInfo.text = tr("playerMenu_button"+_playerIndex)+"\n"
	gameInfo.text +=  tr("difficultyMenu_button"+_difficultyIndex)+"\n"
	gameInfo.text += tr("stageMenu_button"+_stageIndex)+"\n"
	#-------------------------------------------------------------------------------
	gameInfo.text += "-"
	var _stage: Dictionary = _saveData["saveData"][_playerIndex][_difficultyIndex]
	for _i in _stage.size():
		gameInfo.text += str(_stage[str(_i)]["value"])+"-"
#endregion
#-------------------------------------------------------------------------------
