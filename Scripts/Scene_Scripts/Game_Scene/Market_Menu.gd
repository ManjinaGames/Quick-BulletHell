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
@export var cardPrefab: PackedScene
@export var cardButton: Array[Button]
@export var cardIndex: int = 0
@export var cardCatalogue: Array[CardResource]
@export var description: RichTextLabel
#-------------------------------------------------------------------------------
@export_group("Confirm Menu Properties")
@export var confirmCard_Panel: Panel
@export var confirmCard_Artwork: TextureRect
@export var confirmCard_Hold: Label
@export var confirmCard_Price: Label
@export var confirmMenu: MarginContainer
@export var yesButton: Button
@export var noButton: Button
const buttonSize: Vector2 = Vector2(200, 250)
signal closeMarket
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
#region CREATE CARDS FUNCTIONS
func OpenMarket():
	CreateCardButtons()
	gameVariables.MoveToFirstButton(cardButton)
	scrollContainer.custom_minimum_size = buttonSize
	scrollContainer.scroll_horizontal = 0	#NOTA: Por alguna razon el boton no se alinea con el container la primera vez, hay que ayudarlo
	buyMenu.show()
	confirmMenu.hide()
	show()
	await closeMarket
#-------------------------------------------------------------------------------
func CreateCardButtons() ->void:
	ClearContainer()
	for _i in cardCatalogue.size():
		var _b : CardButton = cardPrefab.instantiate() as CardButton
		_b.custom_minimum_size = buttonSize
		if(gameVariables.useCustomButton):
			_b.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		_b.artwork.texture = cardCatalogue[_i].artwork
		_b.hold.text = GetCardText_Hold(_i)
		_b.price.text = GetCardText_Price(_i)
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
func GetCardText_Hold(_i) -> String:
	var _s: String = str(cardCatalogue[_i].maxHold) + " / " + str(cardCatalogue[_i].maxHold)
	return _s
#-------------------------------------------------------------------------------
func GetCardText_Price(_i) -> String:
	var _s: String = "   " + str(cardCatalogue[_i].price) + " $"
	return _s
#-------------------------------------------------------------------------------
func GetCardText_ID(_i:int) -> String:
	var _s: String = cardCatalogue[_i].resource_path.get_file().trim_suffix('.tres')
	return _s
#-------------------------------------------------------------------------------
func GetCardText_Name(_id: String) -> String:
	var _s: String = tr("cardName_ID"+_id)
	return _s
#-------------------------------------------------------------------------------
func GetCardText_Description(_id: String) -> String:
	var _s: String = tr("cardDescription_ID"+_id)
	return _s
#endregion
#-------------------------------------------------------------------------------
#region CARD BUTTON FUNCTIONS
func CardButton_Selected(_i:int) -> void:
	var _id: String = GetCardText_ID(_i)
	var _s: String = "[center][font_size=35]"+ GetCardText_Name(_id) + "[/font_size][font_size=20]\n"
	_s += "ID: " + _id + "\n"
	_s += GetCardText_Description(_id)
	description.text = _s
	gameVariables.CommonSelected()
#-------------------------------------------------------------------------------
func CardButton_Subited(_i:int) -> void:
	cardIndex = _i
	confirmCard_Panel.custom_minimum_size = buttonSize
	confirmCard_Artwork.texture = cardCatalogue[_i].artwork
	confirmCard_Hold.text = GetCardText_Hold(_i)
	confirmCard_Price.text = GetCardText_Price(_i)
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
	closeMarket.emit()
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
