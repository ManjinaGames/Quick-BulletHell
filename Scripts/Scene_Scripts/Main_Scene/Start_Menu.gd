extends Control
class_name Start_Menu
#region VARIABLES
@export var mainScene: Main_Scene
var gameVariables: Game_Variables
#-------------------------------------------------------------------------------
@export var start: Button
@export var back: Button
#endregion
#-------------------------------------------------------------------------------
#region MONOVEHAVIOUR
func Start() -> void:
	gameVariables = get_node("/root/GameVariables")
	#-------------------------------------------------------------------------------
	SetAllButtons()
	hide()
#endregion
#-------------------------------------------------------------------------------
#region BUTTON FUNCTIONS
func SetAllButtons() -> void:
	gameVariables.SetButton(start, gameVariables.CommonSelected, StartButton_Subited, AnyButton_Canceled)
	gameVariables.SetButton(back, gameVariables.CommonSelected, BackButton_Subited, BackButton_Canceled)
#-------------------------------------------------------------------------------
func StartButton_Subited() -> void:
	gameVariables.Save_SaveData(gameVariables.currentSaveData, gameVariables.optionMenu.optionSaveData.saveIndex)
	gameVariables.CommonSubmited()
	get_tree().change_scene_to_file(gameVariables.gameScene_Path)
#-------------------------------------------------------------------------------
func AnyButton_Canceled() -> void:
	gameVariables.MoveToButton(back)
	gameVariables.CommonCanceled()
#-------------------------------------------------------------------------------
func BackButton_Subited() -> void:
	BackButton_Common()
	gameVariables.CommonSubmited()
#-------------------------------------------------------------------------------
func BackButton_Canceled() -> void:
	BackButton_Common()
	gameVariables.CommonCanceled()
#-------------------------------------------------------------------------------
func BackButton_Common() -> void:
	hide()
	gameVariables.MoveToButton(mainScene.stageMenu.button[gameVariables.currentSaveData.stageIndex])
	mainScene.stageMenu.show()
#endregion
#-------------------------------------------------------------------------------
#region IDIOME FUNCTIONS
func SetIdiome():
	start.text = tr("startMenu_button0")
	back.text = tr("startMenu_button2")
#endregion
#-------------------------------------------------------------------------------
