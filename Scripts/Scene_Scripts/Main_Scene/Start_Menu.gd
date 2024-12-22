extends Control
class_name Start_Menu
#region VARIABLES
@export var mainScene: Main_Scene
var singleton: Singleton
#-------------------------------------------------------------------------------
@export var start: Button
@export var back: Button
#endregion
#-------------------------------------------------------------------------------
#region MONOVEHAVIOUR
func Start() -> void:
	singleton = get_node("/root/singleton")
	#-------------------------------------------------------------------------------
	SetAllButtons()
	hide()
#endregion
#-------------------------------------------------------------------------------
#region BUTTON FUNCTIONS
func SetAllButtons() -> void:
	singleton.SetButton(start, singleton.CommonSelected, StartButton_Subited, AnyButton_Canceled)
	singleton.SetButton(back, singleton.CommonSelected, BackButton_Subited, BackButton_Canceled)
#-------------------------------------------------------------------------------
func StartButton_Subited() -> void:
	singleton.Save_SaveData_Json(singleton.optionMenu.optionSaveData_Json["saveIndex"])
	singleton.CommonSubmited()
	get_tree().change_scene_to_file(singleton.gameScene_Path)
#-------------------------------------------------------------------------------
func AnyButton_Canceled() -> void:
	singleton.MoveToButton(back)
	singleton.CommonCanceled()
#-------------------------------------------------------------------------------
func BackButton_Subited() -> void:
	BackButton_Common()
	singleton.CommonSubmited()
#-------------------------------------------------------------------------------
func BackButton_Canceled() -> void:
	BackButton_Common()
	singleton.CommonCanceled()
#-------------------------------------------------------------------------------
func BackButton_Common() -> void:
	hide()
	singleton.MoveToButton(mainScene.stageMenu.button[singleton.currentSaveData_Json["stageIndex"]])
	mainScene.stageMenu.show()
#endregion
#-------------------------------------------------------------------------------
#region IDIOME FUNCTIONS
func SetIdiome():
	start.text = tr("startMenu_button0")
	back.text = tr("startMenu_button2")
#endregion
#-------------------------------------------------------------------------------
