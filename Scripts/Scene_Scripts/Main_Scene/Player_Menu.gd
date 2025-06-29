extends Control
class_name Player_Menu
#region VARIABLES
@export var mainScene: Main_Scene
var singleton: Singleton
#-------------------------------------------------------------------------------
@export var scrollContainer: ScrollContainer
@export var container: HBoxContainer
@export var button: Array[PlayerButton]
@export var playerButton_prefab: PackedScene
const buttonSize: Vector2 = Vector2(900, 450)
@export var back: Button
#endregion
#-------------------------------------------------------------------------------
#region STATE MACHINE
func Start() -> void:
	singleton = get_node("/root/singleton")
	#-------------------------------------------------------------------------------
	SetControlSize(scrollContainer, buttonSize)
	SetAllButtons()
	hide()
#endregion
#-------------------------------------------------------------------------------
#region BUTTON FUNCTIONS
func SetAllButtons() -> void:
	Delete_AllPlayerButtons(button, container)
	Create_AllPlayerButtons()
	singleton.SetButton(back, singleton.CommonSelected, BackButton_Subited, BackButton_Canceled)
#-------------------------------------------------------------------------------
func Create_AllPlayerButtons():
	for _i in singleton.playerResource.size():
		var _playerButton : PlayerButton = playerButton_prefab.instantiate() as PlayerButton
		SetControlSize(_playerButton, buttonSize)
		_playerButton.name_label.text = "Player "+str(_i+1)+"'s Name"
		_playerButton.nickname_label.text = "Player "+str(_i+1)+"'s NickName"
		_playerButton.SetPlayerButtonStats(singleton.playerResource[_i])
		container.add_child(_playerButton)
		button.append(_playerButton)
		singleton.SetButton(_playerButton, func():PlayerButton_Selected(_i), func():PlayerButton_Subited(_i), AnyButton_Canceled)
#-------------------------------------------------------------------------------
func Delete_AllPlayerButtons(_button: Array[PlayerButton], _container: Control) -> void:
	for _cb in _button:
		_cb.queue_free()
	_button.clear()
	ClearContainer(_container)
#-------------------------------------------------------------------------------
func ClearContainer(_container: Control):
	for _child in _container.get_children():
		_child.queue_free()
#-------------------------------------------------------------------------------
func PlayerButton_Subited(_i:int) -> void:
	singleton.currentSaveData_Json["playerIndex"] = _i
	mainScene.mainMenu.SetGameInfo()
	singleton.Save_SaveData_Json(singleton.optionMenu.optionSaveData_Json["saveIndex"])
	BackButton_Common()
	singleton.CommonSubmited()
#-------------------------------------------------------------------------------
func PlayerButton_Selected(_i:int) -> void:
	var _difficulty: int = singleton.currentSaveData_Json["difficultyIndex"]
	var _stage: int = singleton.currentSaveData_Json["stageIndex"]
	mainScene.mainMenu.SetGameInfo2(_i, _difficulty, _stage)
	singleton.CommonSelected()
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
	mainScene.mainMenu.SetGameInfo()
	singleton.MoveToButton(mainScene.mainMenu.button[1])
	mainScene.mainMenu.show()
#endregion
#-------------------------------------------------------------------------------
func SetControlSize(_control:Control, _size: Vector2):
	_control.custom_minimum_size = _size
	_control.size = _size
#-------------------------------------------------------------------------------
func SetIdiome():
	back.text = tr("optionMenu_back")
	#for _i in button.size():
	#	button[_i].text = tr("playerMenu_button"+str(_i))
#-------------------------------------------------------------------------------
