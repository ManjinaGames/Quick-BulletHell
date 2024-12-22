extends Control
class_name Save_Menu2
#region VARIABLES
@export var titleScene: Title_Scene
var singleton: Singleton
#-------------------------------------------------------------------------------
@export var title: Label
@export var saveLabel: Label
#-------------------------------------------------------------------------------
@export_group("What to do Menu")
@export var whatToDo_Menu: PanelContainer
@export var start: Button
@export var delete: Button
@export var back: Button
#-------------------------------------------------------------------------------
@export_group("Confirm Menu")
@export var confirm_Menu: PanelContainer
@export var yes: Button
@export var no: Button
#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
#region STATE MACHINE
func Start():
	singleton = get_node("/root/singleton")
	#-------------------------------------------------------------------------------
	whatToDo_Menu.hide()
	confirm_Menu.hide()
	hide()
#endregion
#-------------------------------------------------------------------------------
#region ENTER THIS MENU
func Set_SaveMenu2(_index:int):
	SetWhatToDoText()
	#-------------------------------------------------------------------------------
	singleton.DisconnectButton(start)
	singleton.DisconnectButton(delete)
	singleton.DisconnectButton(back)
	singleton.SetButton(start, singleton.CommonSelected, func():StartButton_Subited(_index), StartButton_Canceled)
	singleton.SetButton(delete, singleton.CommonSelected, DeleteButton_Subited, StartButton_Canceled)
	singleton.SetButton(back, singleton.CommonSelected, func():CancelButton_Subited(_index), func():CancelButton_Canceled(_index))
	#-------------------------------------------------------------------------------
	singleton.DisconnectButton(yes)
	singleton.DisconnectButton(no)
	singleton.SetButton(yes, singleton.CommonSelected, func():YesButton_Subited(_index), YesButton_Canceled)
	singleton.SetButton(no, singleton.CommonSelected, NoButton_Subited, NoButton_Canceled)
#endregion
#-------------------------------------------------------------------------------
#region WHAT TO DO BUTTON FUNCTIONS
func StartButton_Subited(_index:int) -> void:
	singleton.optionMenu.optionSaveData_Json["saveIndex"] = _index
	singleton.optionMenu.Save_OptionSaveData_Json()
	#-------------------------------------------------------------------------------
	singleton.currentSaveData_Json = singleton.Load_SaveData_Json(_index)
	singleton.Save_SaveData_Json(_index)
	#-------------------------------------------------------------------------------
	singleton.CommonSubmited()
	get_tree().change_scene_to_file(singleton.mainScene_Path)
#-------------------------------------------------------------------------------
func StartButton_Canceled() -> void:
	singleton.MoveToButton(back)
	singleton.CommonCanceled()
#-------------------------------------------------------------------------------
func DeleteButton_Subited() -> void:
	title.text = tr("deleteMenu_title")
	whatToDo_Menu.hide()
	confirm_Menu.show()
	singleton.MoveToButton(no)
	singleton.CommonSubmited()
#-------------------------------------------------------------------------------
func CancelButton_Subited(_index:int) -> void:
	CancelButton_Common(_index)
	singleton.CommonSubmited()
#-------------------------------------------------------------------------------
func CancelButton_Canceled(_index:int) -> void:
	CancelButton_Common(_index)
	singleton.CommonCanceled()
#-------------------------------------------------------------------------------
func CancelButton_Common(_index:int) -> void:
	GoBackToSaveMenu1(_index)
#endregion
#-------------------------------------------------------------------------------
#region CONFIRM BUTTON FUNCTIONS
func YesButton_Subited(_index:int) -> void:
	confirm_Menu.hide()
	singleton.Delete_SaveData_Json(_index)
	singleton.currentSaveData_Json = {}
	titleScene.saveMenu.button[_index].text = titleScene.saveMenu.SetEmptySaveText(_index)
	GoBackToSaveMenu1(_index)
	singleton.CommonSubmited()
#-------------------------------------------------------------------------------
func YesButton_Canceled() -> void:
	singleton.MoveToButton(no)
	singleton.CommonCanceled()
#-------------------------------------------------------------------------------
func NoButton_Subited() -> void:
	NoButton_Common()
	singleton.CommonSubmited()
#-------------------------------------------------------------------------------
func NoButton_Canceled() -> void:
	NoButton_Common()
	singleton.CommonCanceled()
#-------------------------------------------------------------------------------
func NoButton_Common() -> void:
	SetWhatToDoText()
	confirm_Menu.hide()
	whatToDo_Menu.show()
	singleton.MoveToButton(delete)
#endregion
#-------------------------------------------------------------------------------
#region MISC
func SetWhatToDoText():
	title.text = tr("saveMenu2_Title")
#-------------------------------------------------------------------------------
func GoBackToSaveMenu1(_index:int):
	hide()
	titleScene.saveMenu.show()
	singleton.MoveToButton(titleScene.saveMenu.button[_index])
#endregion
#-------------------------------------------------------------------------------
func SetIdiome():
	start.text = tr("saveMenu2_button0")
	delete.text = tr("saveMenu2_button1")
	back.text = tr("optionMenu_back")
	#-------------------------------------------------------------------------------
	yes.text = tr("deleteMenu_button0")
	no.text = tr("deleteMenu_button1")
