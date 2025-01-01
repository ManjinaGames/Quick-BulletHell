extends Panel
class_name Market_Menu
#region VARIABLES
var singleton: Singleton
@export var gameScene: Game_Scene
#-------------------------------------------------------------------------------
@export_group("Buy Menu Properties")
@export var buyMenu: VBoxContainer
@export var scrollContainer: ScrollContainer
@export var cardContainer: HBoxContainer
@export var cardPrefab: PackedScene
@export var cardButton: Array[Button]
@export var cardCatalogue: Array[CardResource]
@export var deckResource: CardResource
@export var description: RichTextLabel
#-------------------------------------------------------------------------------
@export_group("Confirm Menu Properties")
@export var confirmCard_Panel: Panel
@export var confirmCard_Artwork: TextureRect
@export var confirmCard_Hold: Label
@export var confirmCard_Price: Label
@export var confirmMenu: MarginContainer
@export var confirmCard_Title: Label
@export var yesButton: Button
@export var noButton: Button
const buttonSize: Vector2 = Vector2(200, 250)
signal closeMarket
#endregion
#-------------------------------------------------------------------------------
#region STATE MACHINE
func Start():
	singleton = get_node("/root/singleton")
	#-------------------------------------------------------------------------------
	buyMenu.hide()
	confirmMenu.hide()
	hide()
#endregion
#-------------------------------------------------------------------------------
#region CREATE CARDS FUNCTIONS
func OpenMarket():
	CreateCardMarket()
	singleton.MoveToFirstButton(cardButton)
	scrollContainer.custom_minimum_size = buttonSize
	scrollContainer.scroll_horizontal = 0	#NOTA: Por alguna razon el boton no se alinea con el container la primera vez, hay que ayudarlo
	buyMenu.show()
	confirmMenu.hide()
	show()
	await closeMarket
#-------------------------------------------------------------------------------
func CreateCardMarket() ->void:
	DeleteCardButtons()
	CreateDeckButton()
	for _cr in cardCatalogue:
		CreateCardButton(_cr)
#-------------------------------------------------------------------------------
func CreateCardButton(_cr: CardResource):
	var _cb : CardButton = CreateCardButton_Common(_cr)
	singleton.SetButton(_cb, func():CardButton_Selected(_cr), func():CardButton_Subited(_cr, _cb), CardButton_Canceled)
	_cb.hold.text = GetCardText_Hold(_cr)
	_cb.price.text = GetCardText_Price(_cr)
#-------------------------------------------------------------------------------
func CreateDeckButton():
	var _cb : CardButton = CreateCardButton_Common(deckResource)
	singleton.SetButton(_cb, func():CardButton_Selected(deckResource), func():DeckButton_Submit(deckResource, _cb), func():DeckButton_Canceled(deckResource, _cb))
	_cb.hold.text = ""
	_cb.price.text = ""
#-------------------------------------------------------------------------------
func CreateCardButton_Common(_cr: CardResource) -> CardButton:
	var _cb : CardButton = cardPrefab.instantiate() as CardButton
	_cb.custom_minimum_size = buttonSize
	if(singleton.useCustomButton):
		_cb.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	_cb.artwork.texture = _cr.artwork
	cardContainer.add_child(_cb)
	cardButton.append(_cb)
	return _cb
#-------------------------------------------------------------------------------
func DeleteCardButtons() -> void:
	for _cb in cardButton:
		_cb.queue_free()
	cardButton.clear()
	ClearContainer()
#-------------------------------------------------------------------------------
func ClearContainer():
	for _child in cardContainer.get_children():
		_child.queue_free()
#-------------------------------------------------------------------------------
func GetCardText_Hold(_cr:CardResource) -> String:
	var _s: String = str(_cr.maxHold) + " / " + str(_cr.maxHold)
	return _s
#-------------------------------------------------------------------------------
func GetCardText_Price(_cr:CardResource) -> String:
	var _s: String = "   " + str(_cr.price) + " $"
	return _s
#-------------------------------------------------------------------------------
func GetCardText_ID(_cr:CardResource) -> String:
	var _s: String = _cr.resource_path.get_file().trim_suffix('.tres')
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
func CardButton_Selected(_cr:CardResource) -> void:
	var _id: String = GetCardText_ID(_cr)
	var _s: String = "[center][font_size=35]"+ GetCardText_Name(_id) + "[/font_size][font_size=20]\n"
	_s += "ID: " + _id + "\n"
	_s += GetCardText_Description(_id)
	description.text = _s
	singleton.CommonSelected()
#-------------------------------------------------------------------------------
func CardButton_Subited(_cr:CardResource, _cb:CardButton) -> void:
	confirmCard_Hold.text = GetCardText_Hold(_cr)
	confirmCard_Price.text = GetCardText_Price(_cr)
	confirmCard_Title.text = "Do You Want to Buy This Card?"
	CardButton_Submit_Common(_cr, _cb)
	singleton.CommonSubmited()
#-------------------------------------------------------------------------------
func DeckButton_Submit(_cr:CardResource, _cb:CardButton) -> void:
	DeckButton_Common(_cr, _cb)
	singleton.CommonSubmited()
#-------------------------------------------------------------------------------
func DeckButton_Canceled(_cr:CardResource, _cb:CardButton) -> void:
	DeckButton_Common(_cr, _cb)
	singleton.CommonCanceled()
#-------------------------------------------------------------------------------
func DeckButton_Common(_cr:CardResource, _cb:CardButton) -> void:
	confirmCard_Hold.text = ""
	confirmCard_Price.text = ""
	confirmCard_Title.text = "Do You Want to Quit the Market?"
	CardButton_Submit_Common(_cr, _cb)
#-------------------------------------------------------------------------------
func CardButton_Submit_Common(_cr:CardResource, _cb:CardButton) -> void:
	confirmCard_Panel.custom_minimum_size = buttonSize
	confirmCard_Artwork.texture = _cr.artwork
	#-------------------------------------------------------------------------------
	singleton.DisconnectButton(yesButton)
	singleton.DisconnectButton(noButton)
	singleton.SetButton(yesButton, singleton.CommonSelected, func():ConfirmMenu_YesButton_Submited(_cr), ConfirmMenu_YesButton_Canceled)
	singleton.SetButton(noButton, singleton.CommonSelected, func():ConfirmMenu_NoButton_Submited(_cb), func():ConfirmMenu_NoButton_Canceled(_cb))
	#-------------------------------------------------------------------------------
	buyMenu.hide()
	confirmMenu.show()
	singleton.MoveToButton(noButton)
#-------------------------------------------------------------------------------
func CardButton_Canceled() -> void:
	singleton.MoveToFirstButton(cardButton)
	singleton.CommonCanceled()
#endregion
#-------------------------------------------------------------------------------
#region CONFIRM MENU FUNCTIONS
func ConfirmMenu_YesButton_Submited(_cr:CardResource):
	DeleteCardButtons()
	hide()
	closeMarket.emit()
	singleton.CommonSubmited()
#-------------------------------------------------------------------------------
func ConfirmMenu_YesButton_Canceled():
	singleton.MoveToButton(noButton)
	singleton.CommonCanceled()
#-------------------------------------------------------------------------------
func ConfirmMenu_NoButton_Submited(_cb:CardButton):
	ConfurmMenu_NoButton_Common(_cb)
	singleton.CommonSubmited()
#-------------------------------------------------------------------------------
func ConfirmMenu_NoButton_Canceled(_cb:CardButton):
	ConfurmMenu_NoButton_Common(_cb)
	singleton.CommonCanceled()
#-------------------------------------------------------------------------------
func ConfurmMenu_NoButton_Common(_cb:CardButton):
	confirmMenu.hide()
	buyMenu.show()
	singleton.MoveToButton(_cb)
#endregion
#-------------------------------------------------------------------------------
