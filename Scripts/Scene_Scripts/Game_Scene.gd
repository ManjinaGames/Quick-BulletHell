extends Node
class_name Game_Scene
#-------------------------------------------------------------------------------
enum GAME_STATE{IN_GAMEPLAY, IN_CUTIN, IN_MARKET, IN_OPTION_MENU, IN_DIALOGUE, IN_GAMEOVER}
#region VARIABLES
var singleton: Singleton
#-------------------------------------------------------------------------------
var myGAME_STATE: GAME_STATE = GAME_STATE.IN_GAMEPLAY
var inPause: bool = false
#-------------------------------------------------------------------------------
@export var currentLayer: CanvasLayer
@export var pauseMenu: Pause_Menu
@export var gameoverMenu: GameOver_Menu
@export var marketMenu: Market_Menu
@export var dialogueMenu: Dialogue_Menu
#-------------------------------------------------------------------------------
@export var timerLabel: Label
var timer: int
var difficulty: float
@export var content: Control
@export var player: Player
var cardInventory: Dictionary[CardResource, int]
#-------------------------------------------------------------------------------
@export var enemy_Prefab: PackedScene
@export var bullet_Prefab: PackedScene
@export var item_Prefab: PackedScene
#-------------------------------------------------------------------------------
var bulletDictionary: Dictionary[String, BulletResource]
@export var bulletDictionary_Path: String = "res://Resources/Bullets/"
#-------------------------------------------------------------------------------
@export var difficultyLabel: Label
@export var maxScoreLabel_title: RichTextLabel
@export var maxScoreLabel_Num: RichTextLabel
@export var scoreLabel_title: RichTextLabel
@export var scoreLabel_Num: RichTextLabel
@export var powerLabel_title: RichTextLabel
@export var powerLabel_Num: RichTextLabel
@export var livesLabel_title: RichTextLabel
@export var livesLabel_Num: RichTextLabel
@export var moneyLabel_title: RichTextLabel
@export var moneyLabel_Num: RichTextLabel
@export var maxMoneyLabel_Num: RichTextLabel
@export var leftLabel: RichTextLabel
#-------------------------------------------------------------------------------
@export var completedPanel: PanelContainer
@export var completedLabel: Label
#-------------------------------------------------------------------------------
var enemyBullets_Enabled_Array: Array[Bullet]
var enemyBullets_Disabled_Array: Array[Bullet]
#-------------------------------------------------------------------------------
var playerBullets_Enabled_Array: Array[Bullet]
var playerBullets_Disabled_Array: Array[Bullet]
#-------------------------------------------------------------------------------
var items_Enabled_Array: Array[Item]
var items_Disabled_Array: Array[Item]
#-------------------------------------------------------------------------------
var tween_Array: Array[Tween]
#-------------------------------------------------------------------------------
var height: float
var width: float
#-------------------------------------------------------------------------------
var playerLimitsX: Vector2
var playerLimitsY: Vector2
#-------------------------------------------------------------------------------
var enemyLimitsX: Vector2
var enemyLimitsY: Vector2
#-------------------------------------------------------------------------------
var bossStartingPosition: Vector2
#-------------------------------------------------------------------------------
var lifePoints: int
var powerPoints: int
var moneyPoints: int
var scorePoints: int
#-------------------------------------------------------------------------------
var deltaTimeScale: float = 1
#-------------------------------------------------------------------------------
var enemy_tween_array: Array[Tween]
#endregion
#-------------------------------------------------------------------------------
#region MONOVEHAVIOUR
func _ready():
	singleton = get_node("/root/singleton")
	#-------------------------------------------------------------------------------
	pauseMenu.Start()
	gameoverMenu.Start()
	marketMenu.Start()
	dialogueMenu.Start()
	#-------------------------------------------------------------------------------
	SetIdiome()
	#-------------------------------------------------------------------------------
	singleton.PlayBGM(singleton.bgmStage1)
	get_tree().set_deferred("paused", false)
	currentLayer.show()
	await BeginGame()
#-------------------------------------------------------------------------------
func _physics_process(_delta:float) -> void:
	deltaTimeScale = Engine.time_scale
	tween_Array = get_tree().get_processed_tweens()
	Debug_Information()
	#-------------------------------------------------------------------------------
	for _i in range(enemyBullets_Enabled_Array.size()-1,-1,-1):
		enemyBullets_Enabled_Array[_i].physics_Update.call()
	#-------------------------------------------------------------------------------
	for _i in range(playerBullets_Enabled_Array.size()-1,-1,-1):
		playerBullets_Enabled_Array[_i].physics_Update.call()
	#-------------------------------------------------------------------------------
	for _i in range(items_Enabled_Array.size()-1,-1,-1):
		items_Enabled_Array[_i].physics_Update.call()
	#-------------------------------------------------------------------------------
	match(myGAME_STATE):
		GAME_STATE.IN_GAMEPLAY:
			PlayerMovement()
			PauseGame()
			return
		#-------------------------------------------------------------------------------
		GAME_STATE.IN_CUTIN:
			PlayerMovement()
			PauseGame()
			return
		#-------------------------------------------------------------------------------
		GAME_STATE.IN_MARKET:
			pass
		#-------------------------------------------------------------------------------
		GAME_STATE.IN_OPTION_MENU:
			pass
		#-------------------------------------------------------------------------------
		GAME_STATE.IN_DIALOGUE:
			PlayerMovement()
			if(Input.is_action_just_pressed("input_Shoot")):
				dialogueMenu.isNextPress = true
		#-------------------------------------------------------------------------------
		GAME_STATE.IN_GAMEOVER:
			pass
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
#region PLAYER FUNCTIONS
func PlayerMovement() -> void:
	if(player.myPLAYER_STATE == Player.PLAYER_STATE.DEATH):
		return
	#-------------------------------------------------------------------------------
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if(input_dir != Vector2.ZERO):
		input_dir.normalized()
		var myPosition: Vector2 = player.position
		if(Input.is_action_pressed("input_Focus")):
			myPosition += input_dir * player.playerResource.focusSpeed * deltaTimeScale
		#-------------------------------------------------------------------------------
		else:
			myPosition += input_dir * player.playerResource.normalSpeed * deltaTimeScale
		#-------------------------------------------------------------------------------
		myPosition.x = clampf(myPosition.x, playerLimitsX.x, playerLimitsX.y)
		myPosition.y = clampf(myPosition.y, playerLimitsY.x, playerLimitsY.y)
		player.position = myPosition
	#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
#region PAUSE INPUTS
func PauseGame() -> void:
	if(myGAME_STATE == GAME_STATE.IN_GAMEOVER):
		return
	#-------------------------------------------------------------------------------
	if(Input.is_action_just_pressed("input_Pause")):
		pauseMenu.show()
		StopTime()
		singleton.MoveToButton(pauseMenu.continuar)
#-------------------------------------------------------------------------------
func StopTime():
	singleton.playPosition = singleton.bgmPlayer.get_playback_position()
	singleton.bgmPlayer.stop()
	get_tree().set_deferred("paused", true)
#-------------------------------------------------------------------------------
func PauseOff():
	pauseMenu.hide()
	myGAME_STATE = GAME_STATE.IN_GAMEPLAY
	get_tree().set_deferred("paused", false)
	singleton.bgmPlayer.play(singleton.playPosition)
#endregion
#-------------------------------------------------------------------------------
#region UI FINCTIONS
func SetGameLimits() -> void:
	await content.resized
	#-------------------------------------------------------------------------------
	height = content.size.y
	width = content.size.x
	#-------------------------------------------------------------------------------
	var _offSet: float = 10
	playerLimitsX = Vector2(_offSet, width-_offSet)
	playerLimitsY = Vector2(_offSet, height-_offSet)
	#-------------------------------------------------------------------------------
	enemyLimitsX = Vector2(0, width)
	enemyLimitsY = Vector2(0, height)
	#-------------------------------------------------------------------------------
	bossStartingPosition = Vector2(width*0.5, height*0.25)
#-------------------------------------------------------------------------------
func Debug_Information() -> void:
	var _s: String = ""
	_s += "-------------------------------------------------------\n"
	_s += str(Engine.get_frames_per_second()) + " fps.\n"
	_s += "Tweens: "+str(tween_Array.size())+"\n"
	_s += "-------------------------------------------------------\n"
	_s += "Enemy Bullets Enabled: " + str(enemyBullets_Enabled_Array.size())+"\n"
	_s += "Enemy Bullets Disabled: " + str(enemyBullets_Disabled_Array.size())+"\n"
	_s += "-------------------------------------------------------\n"
	_s += "Player Bullets Enabled: " + str(playerBullets_Enabled_Array.size())+"\n"
	_s += "Player Bullets Disabled: " + str(playerBullets_Disabled_Array.size())+"\n"
	_s += "-------------------------------------------------------\n"
	_s += "Items Enabled: " + str(items_Enabled_Array.size())+"\n"
	_s += "Items Disabled: " + str(items_Disabled_Array.size())+"\n"
	_s += "-------------------------------------------------------\n"
	_s += "GAME_STATE." + GAME_STATE.keys()[myGAME_STATE]+"\n"
	_s += "PLAYER_STATE." + Player.PLAYER_STATE.keys()[player.myPLAYER_STATE]+"\n"
	_s += "-------------------------------------------------------\n"
	leftLabel.text = _s
#-------------------------------------------------------------------------------
func SetScore() -> void:
	var _s: String = str(scorePoints).pad_zeros(9)
	_s = _s.insert(_s.length()-3,",")
	_s = _s.insert(_s.length()-7,",")
	scoreLabel_Num.text = "[center]"+_s+"[/center]"
#-------------------------------------------------------------------------------
func SetInfoText_Life() -> void:
	livesLabel_Num.text = GetInfoText_LifePower(lifePoints, player.playerResource.maxLives)
#-------------------------------------------------------------------------------
func SetInfoText_Power() -> void:
	powerLabel_Num.text = GetInfoText_LifePower(powerPoints, player.playerResource.maxPower)
#-------------------------------------------------------------------------------
func GetInfoText_LifePower(_point:int, _maxPoint:int) -> String:
	var _s: String = "[center]"+str(_point).pad_zeros(2)+" / "+str(_maxPoint).pad_zeros(2)+"[/center]"
	return _s
#-------------------------------------------------------------------------------
func SetInfoText_Death():
	livesLabel_Num.text = "[center]"+"  --"+" / "+str(player.playerResource.maxLives).pad_zeros(2)+"[/center]"
#-------------------------------------------------------------------------------
func SetMoney() -> void:
	moneyLabel_Num.text = "[center]"+str(moneyPoints)+" G[/center]"
	#-------------------------------------------------------------------------------
func SetMaxMoney() -> void:
	maxMoneyLabel_Num.text = "[center]"+str(player.playerResource.maxMoney)+" G[/center]"
#endregion
#-------------------------------------------------------------------------------
#region START FUNCTIONS
func BeginGame() -> void:
	var _difficulty: int = singleton.currentSaveData_Json.get("difficultyIndex", 0)
	difficulty = float(_difficulty)
	difficultyLabel.text = tr("difficultyMenu_button"+str(_difficulty))
	#-------------------------------------------------------------------------------
	await SetGameLimits()
	player.SetPlayer(singleton.Copy_CurrentPlayer())
	#-------------------------------------------------------------------------------
	SetScore()
	SetMoney()
	SetMaxMoney()
	lifePoints = int(float(player.playerResource.maxLives)*1)
	SetInfoText_Life()
	powerPoints = int(float(player.playerResource.maxPower)*1)
	SetInfoText_Power()
	#-------------------------------------------------------------------------------
	completedPanel.hide()
	completedLabel.text = ""
	timerLabel.text = ""
	#-------------------------------------------------------------------------------
	player.position = Vector2(width*0.5, height*0.85)
	player.myPLAYER_STATE = Player.PLAYER_STATE.ALIVE
	myGAME_STATE = GAME_STATE.IN_GAMEPLAY
	cardInventory = {}
	#-------------------------------------------------------------------------------
	Create_EnemyBullets_Disabled(3000)
	Create_PlayerBullets_Disabled(50)
	Create_Items_Disabled(2000)
	#-------------------------------------------------------------------------------
	TimeLimit(15)
	await Seconds(3)
	Create_Items(width*0.5, height*0.5, 200, 1000)
	await Seconds(3.0)
	Create_SpellCard()
	#-------------------------------------------------------------------------------
	LoadBulletDatabase()
#-------------------------------------------------------------------------------
func LoadBulletDatabase():
	bulletDictionary.clear()
	#-------------------------------------------------------------------------------
	var dir_array = DirAccess.get_files_at(bulletDictionary_Path)
	if(dir_array):
		for _i in dir_array.size():
			var _base_name: String = dir_array[_i].get_slice(".",0)
			var _bulletResource: BulletResource = load(bulletDictionary_Path+"/"+_base_name+".tres") as BulletResource
			bulletDictionary[_base_name] = _bulletResource
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#endregion
#-------------------------------------------------------------------------------
#region STAGE FUNCTIONS COMMON
#-------------------------------------------------------------------------------
func EnableStage(_i:int):
	var _playerIndex: StringName = str(int(singleton.currentSaveData_Json["playerIndex"]))
	var _difficultyIndex: StringName = str(int(singleton.currentSaveData_Json["difficultyIndex"]))
	if(singleton.currentSaveData_Json["saveData"][_playerIndex][_difficultyIndex][str(_i)]["value"] == singleton.STAGE_STATE.DISABLED):
		singleton.currentSaveData_Json["saveData"][_playerIndex][_difficultyIndex][str(_i)]["value"] = singleton.STAGE_STATE.ENABLED
#-------------------------------------------------------------------------------
func CompletedStage(_i:int):
	var _playerIndex: StringName = str(int(singleton.currentSaveData_Json["playerIndex"]))
	var _difficultyIndex: StringName = str(int(singleton.currentSaveData_Json["difficultyIndex"]))
	singleton.currentSaveData_Json["saveData"][_playerIndex][_difficultyIndex][str(_i)]["value"] = singleton.STAGE_STATE.COMPLETED
#-------------------------------------------------------------------------------
func GoToMainScene():
	singleton.PlayBGM(singleton.bgmTitle)
	get_tree().set_deferred("paused", false)
	get_tree().change_scene_to_file(singleton.mainScene_Path)
#endregion
#-------------------------------------------------------------------------------
func Create_SpellCard():
	var _tween_array: Array[Tween] = CreateTween_Array(1)
	enemy_tween_array = _tween_array
	#-------------------------------------------------------------------------------
	_tween_array[0].set_loops()
	Create_SpellCard_Tween(_tween_array[0], 1)
	Create_SpellCard_Tween(_tween_array[0], -1)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Create_SpellCard_Tween(_tween:Tween, _mirror: float):
	var _dir: float
	var _dir2: float = 0.0
	var _max1: float = 40.0
	var _max2: float = 40.0
	var _vel1: float = 4.0
	var _vel2: float = 1.0
	var _dvel: float = (_vel2-_vel1)/_max2
	#-------------------------------------------------------------------------------
	for _j in _max2:
		_dir = 0.0
		for _i in _max1:
			_tween.tween_callback(func():Create_SpellCard_bullet(_dir+_dir2*_mirror, _max1, _vel1, _mirror))
			_dir += 360/_max1
		#-------------------------------------------------------------------------------
		_tween.tween_interval(0.1)
		_vel1 += _dvel
		_dir2 += 2
	#-------------------------------------------------------------------------------
	_tween.set_parallel(false)
	_tween.tween_interval(4.0)
#-------------------------------------------------------------------------------
func Create_SpellCard_bullet(_dir:float, _max1:float, _vel:float, _mirror: float):
	var _bullet: Bullet = Create_EnemyBullet(width*0.5, height*0.5, 4.0, _dir)
	_dir += 360/_max1
	_bullet.tween_Array = CreateTween_Array(1)
	#-------------------------------------------------------------------------------
	_bullet.tween_Array[0].tween_property(_bullet, "vel",0.5, 1.0)
	_bullet.tween_Array[0].parallel().tween_property(_bullet, "dir",_bullet.dir+30*_mirror, 1.0)
	_bullet.tween_Array[0].tween_property(_bullet, "dir",_bullet.dir+165*_mirror, 0.25)
	_bullet.tween_Array[0].tween_property(_bullet, "vel",_vel, 1.0)
	_bullet.tween_Array[0].parallel().tween_property(_bullet, "dir",_bullet.dir+270*_mirror, 3.0)
#-------------------------------------------------------------------------------
func Create_EnemyBullets_Disabled(_iMax:int):
	for _i in _iMax:
		var _bullet: Bullet = bullet_Prefab.instantiate() as Bullet
		enemyBullets_Disabled_Array.append(_bullet)
		_bullet.hide()
		_bullet.physics_Update = func(): Bullet_PhysicsUpdate(_bullet)
		content.add_child(_bullet)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Create_EnemyBullet(_x:float, _y:float, _v:float, _dir:float) ->Bullet:
	var _bullet: Bullet
	#-------------------------------------------------------------------------------
	if(enemyBullets_Disabled_Array.size() > 0):
		_bullet = enemyBullets_Disabled_Array[0]
		_bullet.show()
		enemyBullets_Disabled_Array.erase(_bullet)
	#-------------------------------------------------------------------------------
	else:
		_bullet = bullet_Prefab.instantiate() as Bullet
		_bullet.physics_Update = func(): Bullet_PhysicsUpdate(_bullet)
		content.add_child(_bullet)
	#-------------------------------------------------------------------------------
	enemyBullets_Enabled_Array.append(_bullet)
	#-------------------------------------------------------------------------------
	_bullet.position = Vector2(_x, _y)
	_bullet.isGrazed = false
	_bullet.dir = _dir
	_bullet.vel = _v
	#-------------------------------------------------------------------------------
	return _bullet
#-------------------------------------------------------------------------------
func Create_PlayerBullets_Disabled(_iMax:int):
	for _i in _iMax:
		var _bullet: Bullet = bullet_Prefab.instantiate() as Bullet
		playerBullets_Disabled_Array.append(_bullet)
		_bullet.hide()
		content.add_child(_bullet)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Create_Items_Disabled(_iMax:int):
	for _i in _iMax:
		var _item: Item = item_Prefab.instantiate() as Item
		items_Disabled_Array.append(_item)
		_item.physics_Update = func(): Items_PhysicsUpdate(_item)
		_item.hide()
		content.add_child(_item)
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Create_Items(_x:float, _y:float, _rad: float, _num:int):
	for _i in _num:
		Create_Item(_x+randf_range(-_rad,_rad), _y+randf_range(-_rad,_rad))
#-------------------------------------------------------------------------------
func Create_Item(_x:float, _y:float):
	var _item: Item
	#-------------------------------------------------------------------------------
	if(items_Disabled_Array.size()>0):
		_item = items_Disabled_Array[0]
		items_Disabled_Array.erase(_item)
		_item.show()
	#-------------------------------------------------------------------------------
	else:
		_item = item_Prefab.instantiate() as Item
		_item.physics_Update = func(): Items_PhysicsUpdate(_item)
		content.add_child(_item)
	#-------------------------------------------------------------------------------
	items_Enabled_Array.append(_item)
	#-------------------------------------------------------------------------------
	_item.myITEM_STATE = Item.ITEM_STATE.SPIN
	_item.velocity = Vector2(0, -5)
	_x = clamp(_x, playerLimitsX.x, playerLimitsX.y)
	_y = clamp(_y, playerLimitsY.x, playerLimitsY.y)
	_item.position = Vector2(_x, _y)
#-------------------------------------------------------------------------------
func Items_PhysicsUpdate(_item:Item):
	var _velY_Max: float = 3.0
	var _velY_Accel: float = 0.05
	var _magnetVel: float = 8.0
	match(_item.myITEM_STATE):
		Item.ITEM_STATE.SPIN:
			if(_item.velocity.y <= 0):
				_item.velocity.y += _velY_Accel * deltaTimeScale
				_item.position.y += _item.velocity.y * deltaTimeScale
				_item.rotation += 0.5 * deltaTimeScale
				return
			#-------------------------------------------------------------------------------
			else:
				_item.rotation = 0
				_item.myITEM_STATE = Item.ITEM_STATE.FALL
				return
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
		Item.ITEM_STATE.FALL:
			if(_item.position.y <= height):
				if(_item.velocity.y > _velY_Max):
					_item.velocity.y = _velY_Max
				#-------------------------------------------------------------------------------
				elif(_item.velocity.y < _velY_Max):
					_item.velocity.y += _velY_Accel * deltaTimeScale
				#-------------------------------------------------------------------------------
				_item.position.y += _item.velocity.y * deltaTimeScale
				#-------------------------------------------------------------------------------
				if(_item.position.distance_to(player.position)< 98.0 and player.myPLAYER_STATE != Player.PLAYER_STATE.DEATH):
					_item.myITEM_STATE = Item.ITEM_STATE.IMANTED
					return
				#-------------------------------------------------------------------------------
				elif(!CanPlayerShoot() and player.myPLAYER_STATE != Player.PLAYER_STATE.DEATH):
					_item.myITEM_STATE = Item.ITEM_STATE.IMANTED
					return
				#-------------------------------------------------------------------------------
			#-------------------------------------------------------------------------------
			else:
				DestroyItem(_item)
				return
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
		Item.ITEM_STATE.IMANTED:
			var _vel: Vector2 = (player.position - _item.position)
			if(_vel.length_squared() > 144.0):
				var _dir = atan2(_vel.y, _vel.x)
				var _vel2 = Vector2(cos(_dir), sin(_dir))
				_item.position += _vel2 * _magnetVel * deltaTimeScale
			#-------------------------------------------------------------------------------
			else:
				scorePoints += 10
				moneyPoints += 1
				SetScore()
				SetMoney()
				DestroyItem(_item)
				return
			#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func Bullet_PhysicsUpdate(_bullet: Bullet):
	if(_bullet.position.x > enemyLimitsX.x and _bullet.position.x < enemyLimitsX.y):
		if(_bullet.position.y > enemyLimitsY.x and _bullet.position.y < enemyLimitsY.y):
			if(_bullet.position.distance_to(player.position)< 34.0 and !_bullet.isGrazed):
				Create_Item(_bullet.position.x, _bullet.position.y)
				_bullet.isGrazed = true
			#-------------------------------------------------------------------------------
			if(_bullet.position.distance_to(player.position)> 10.0):
				var _dir2: float = deg_to_rad(_bullet.dir)
				_bullet.velocity.x = _bullet.vel * cos(_dir2)
				_bullet.velocity.y = _bullet.vel * sin(_dir2)
				_bullet.position += _bullet.velocity * deltaTimeScale
				_bullet.rotation_degrees = _bullet.dir+90
				return
			#-------------------------------------------------------------------------------
			else:
				Player_Shooted()
				DestroyBullet(_bullet)
				return
			#-------------------------------------------------------------------------------
		else:
			DestroyBullet(_bullet)
			return
		#-------------------------------------------------------------------------------
	else:
		DestroyBullet(_bullet)
		return
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func DestroyBullet(_bullet: Bullet):
	KillTween_Array(_bullet.tween_Array)
	enemyBullets_Enabled_Array.erase(_bullet)
	enemyBullets_Disabled_Array.append(_bullet)
	_bullet.hide()
#-------------------------------------------------------------------------------
func Player_Shooted():
	lifePoints -= 1
	if(lifePoints < 0):
		SetInfoText_Death()
	else:
		SetInfoText_Life()
#-------------------------------------------------------------------------------
func DestroyItem(_item:Item) -> void:
	items_Enabled_Array.erase(_item)
	items_Disabled_Array.append(_item)
	_item.hide()
#-------------------------------------------------------------------------------
func CanPlayerShoot() -> bool:
	if(myGAME_STATE == GAME_STATE.IN_GAMEPLAY or myGAME_STATE == GAME_STATE.IN_CUTIN):
		return true
	#-------------------------------------------------------------------------------
	else:
		return false
	#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func TimeLimit(_iMax: int):
	timer = _iMax
	timerLabel.show()
	#-------------------------------------------------------------------------------
	timerLabel.text = str(timer).pad_zeros(2)+" / " +str(_iMax).pad_zeros(2)
	await Seconds(1.0)
	#-------------------------------------------------------------------------------
	for _i in _iMax:
		timer-=1
		timerLabel.text = str(timer).pad_zeros(2)+" / " +str(_iMax).pad_zeros(2)
		await Seconds(1.0)
	#-------------------------------------------------------------------------------
	timerLabel.text = ""
	timerLabel.hide()
	#-------------------------------------------------------------------------------
	for _i in range(enemyBullets_Enabled_Array.size()-1, -1, -1):
		DestroyBullet(enemyBullets_Enabled_Array[_i])
	#-------------------------------------------------------------------------------
	KillTween_Array(enemy_tween_array)
#-------------------------------------------------------------------------------
func Seconds(_f:float):
	await get_tree().create_timer(_f, false).timeout
#-------------------------------------------------------------------------------
#region ARRAY[TWEEN] FUNCTIONS
func CreateTween_Array(_size: int) ->Array[Tween]:
	var _tween_Array: Array[Tween]
	for _i in _size:
		var _tween: Tween = create_tween()
		_tween_Array.append(_tween)
		_tween.finished.connect(func():_tween_Array.erase(_tween))
	return _tween_Array
#-------------------------------------------------------------------------------
func PlayTween_Array(_tween_Array: Array[Tween]):
	for _i in _tween_Array.size():
		_tween_Array[_i].play()
#-------------------------------------------------------------------------------
func StopTween_Array(_tween_Array: Array[Tween]):
	for _i in _tween_Array.size():
		_tween_Array[_i].stop()
#-------------------------------------------------------------------------------
func KillTween_Array(_tween_Array: Array[Tween]):
	for _i in range(_tween_Array.size()-1, -1, -1):
		_tween_Array[_i].kill()
		_tween_Array[_i].finished.emit()
#endregion
#-------------------------------------------------------------------------------
#region IDIOME FUNCTIONS
func SetIdiome():
	singleton.DisconnectAll(singleton.optionMenu.idiomeChange)
	#-------------------------------------------------------------------------------
	singleton.optionMenu.idiomeChange.connect(pauseMenu.SetIdiome)
	singleton.optionMenu.idiomeChange.connect(SetIdiome2)
	#-------------------------------------------------------------------------------
	pauseMenu.SetIdiome()
	SetIdiome2()
#-------------------------------------------------------------------------------
func SetIdiome2():
	maxScoreLabel_title.text = "[u]"+tr("gameUI_maxScore")+":[/u]"
	scoreLabel_title.text = "[u]"+tr("gameUI_score")+":[/u]"
	livesLabel_title.text = "[u]"+tr("gameUI_lives")+":[/u]"
	powerLabel_title.text = "[u]"+tr("gameUI_power")+":[/u]"
#endregion
#-------------------------------------------------------------------------------
