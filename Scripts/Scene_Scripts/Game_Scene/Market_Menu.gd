extends Panel
class_name Market_Menu
#region VARIABLES
var gameVariables: Game_Variables
@export var gameScene: Game_Scene
#-------------------------------------------------------------------------------
@export_group("Buy Menu Properties")
@export var buyMenu: VBoxContainer
@export var scrollContainer: ScrollContainer
@export var cardContainer: HBoxContainer
@export var cardButton: Array[Button]
@export var cardIndex: int = 0
@export var cardCatalogue: Array[CardResource]
@export var description: RichTextLabel
#-------------------------------------------------------------------------------
@export_group("Confirm Menu Properties")
@export var confirmCardLabel: Label
@export var confirmMenu: VBoxContainer
@export var yesButton: Button
@export var noButton: Button
const buttonSize: Vector2 = Vector2(198, 250)
#endregion
#-------------------------------------------------------------------------------
#region STATE MACHINE
func Start():
	gameVariables = get_node("/root/GameVariables")
	#-------------------------------------------------------------------------------
	gameVariables.SetButton(yesButton, gameVariables.CommonSelected, ConfirmMenu_YesButton_Submited, ConfirmMenu_YesButton_Canceled)
	gameVariables.SetButton(noButton, gameVariables.CommonSelected, ConfirmMenu_NoButton_Submited, ConfirmMenu_NoButton_Canceled)
	#-------------------------------------------------------------------------------
	buyMenu.hide()
	confirmMenu.hide()
	hide()
#endregion
#-------------------------------------------------------------------------------
func OpenMarket():
	CreateCardButtons()
	gameVariables.MoveToFirstButton(cardButton)
	scrollContainer.scroll_horizontal = 0	#NOTA: Por alguna razon el boton no se alinea con el container la primera vez, hay que ayudarlo
	buyMenu.show()
	confirmMenu.hide()
	show()
#-------------------------------------------------------------------------------
#region CREATE CARDS FUNCTIONS
func CreateCardButtons() ->void:
	ClearContainer()
	for _i in cardCatalogue.size():
		var _b : Button = Button.new()
		_b.custom_minimum_size = buttonSize
		_b.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		_b.text = SetCardTextNumber(_i)
		gameVariables.SetButton(_b, func():CardButton_Selected(_i), func():CardButton_Subited(_i), CardButton_Canceled)
		cardContainer.add_child(_b)
		cardButton.append(_b)
#-------------------------------------------------------------------------------
func DeleteCardButtons() -> void:
	for _b in cardButton:
		_b.queue_free()
	cardButton.clear()
	ClearContainer()
#-------------------------------------------------------------------------------
func ClearContainer():
	for _child in cardContainer.get_children():
		_child.queue_free()
#-------------------------------------------------------------------------------
func SetCardTextNumber(_i:int) -> String:
	var _s: String = "Card N°"+str(_i)
	return _s
#endregion
#-------------------------------------------------------------------------------
#region BUY MENU FUNCTIONS
func CardButton_Selected(_i:int) -> void:
	var _s: String = "[center][font_size=35]"+ cardCatalogue[_i].title + "[/font_size][font_size=20]\n"
	_s += cardCatalogue[_i].description
	description.text = _s
	gameVariables.CommonSelected()
#-------------------------------------------------------------------------------
func CardButton_Subited(_i:int) -> void:
	cardIndex = _i
	confirmCardLabel.text = SetCardTextNumber(_i)
	buyMenu.hide()
	confirmMenu.show()
	gameVariables.MoveToButton(noButton)
	gameVariables.CommonSubmited()
#-------------------------------------------------------------------------------
func CardButton_Canceled() -> void:
	gameVariables.MoveToFirstButton(cardButton)
	gameVariables.CommonCanceled()
#endregion
#-------------------------------------------------------------------------------
#region CONFIRM MENU FUNCTIONS
func ConfirmMenu_YesButton_Submited():
	DeleteCardButtons()
	hide()
	gameScene.endMoment.emit()
	gameVariables.CommonSubmited()
#-------------------------------------------------------------------------------
func ConfirmMenu_YesButton_Canceled():
	gameVariables.MoveToButton(noButton)
	gameVariables.CommonCanceled()
#-------------------------------------------------------------------------------
func ConfirmMenu_NoButton_Submited():
	ConfurmMenu_NoButton_Common()
	gameVariables.CommonSubmited()
#-------------------------------------------------------------------------------
func ConfirmMenu_NoButton_Canceled():
	ConfurmMenu_NoButton_Common()
	gameVariables.CommonCanceled()
#-------------------------------------------------------------------------------
func ConfurmMenu_NoButton_Common():
	confirmMenu.hide()
	buyMenu.show()
	gameVariables.MoveToButton(cardButton[cardIndex])
#endregion
#-------------------------------------------------------------------------------
