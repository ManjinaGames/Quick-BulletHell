extends Node
class_name Game_Scene
#-------------------------------------------------------------------------------
enum PLAY_STATE{IN_GAME, IN_MARKET, IN_OPTION_MENU}
enum ITEM_STATE{FREED, IMANTED}
#region VARIABLES
var gameVariables: Game_Variables
#-------------------------------------------------------------------------------
var myPLAY_STATE: PLAY_STATE = PLAY_STATE.IN_GAME
var inPause: bool = false
#-------------------------------------------------------------------------------
@export var currentLayer: CanvasLayer
@export var pauseMenu: Pause_Menu
@export var marketMenu: Market_Menu
#-------------------------------------------------------------------------------
@export var window: Control
@export var timerLabel: Label
var timer: int
@export var content: Control
@export var player: Player
#-------------------------------------------------------------------------------
@export var enemy_Prefab: PackedScene
@export var enemyBullet_Prefab: PackedScene
@export var item_Prefab: PackedScene
#-------------------------------------------------------------------------------
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
var enemyBulletsEnabled: Array[Bullet]
var enemyBulletsDisabled: Array[Bullet]
var playerBulletsEnabled: Array[Bullet]
var playerBulletsDisabled: Array[Bullet]
var itemsEnabled: Array[Item]
var itemsDisabled: Array[Item]
#-------------------------------------------------------------------------------
@export_flags_2d_physics var playerLayer: int
@export_flags_2d_physics var grazeLayer: int
@export_flags_2d_physics var magnetLayer: int
@export_flags_2d_physics var enemyLayer: int
#-------------------------------------------------------------------------------
var height: float
var unitY: float
var width: float
var unitX: float
var centerX: float
var maxX: float
var minX: float
var centerY: float
var maxY: float
var minY: float
#-------------------------------------------------------------------------------
var lifePoints: int
var powerPoints: int
var moneyPoints: int
var scorePoints: int
#-------------------------------------------------------------------------------
var _direct_space_state :PhysicsDirectSpaceState2D
#-------------------------------------------------------------------------------
signal frame
signal endMoment
#endregion
#-------------------------------------------------------------------------------
#region MONOVEHAVIOUR
func _ready():
	gameVariables = get_node("/root/GameVariables")
	#-------------------------------------------------------------------------------
	_direct_space_state = window.get_world_2d().direct_space_state
	#-------------------------------------------------------------------------------
	pauseMenu.Start()
	marketMenu.Start()
	#-------------------------------------------------------------------------------
	SetIdiome()
	#-------------------------------------------------------------------------------
	gameVariables.PlayBGM(gameVariables.bgmStage1)
	get_tree().set_deferred("paused", false)
	currentLayer.show()
	BeginGame()
#-------------------------------------------------------------------------------
func _physics_process(_delta:float) -> void:
	PlayerMovement()
	PauseGame()
	frame.emit()
#endregion
#-------------------------------------------------------------------------------
#region PLAYER FUNCTIONS
func PlayerMovement() -> void:
	if(myPLAY_STATE != PLAY_STATE.IN_GAME):
		return
	#-------------------------------------------------------------------------------
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if(input_dir != Vector2.ZERO):
		input_dir.normalized()
		var myPosition: Vector2 = player.position
		if(Input.is_action_pressed("input_Focus")):
			myPosition += input_dir * player.focusSpeed
		else:
			myPosition += input_dir * player.normalSpeed
		myPosition.x = clampf(myPosition.x, minX, maxX)
		myPosition.y = clampf(myPosition.y, minY, maxY)
		player.position = myPosition
#endregion
#-------------------------------------------------------------------------------
#region PAUSE INPUTS
func PauseGame() -> void:
	if(myPLAY_STATE != PLAY_STATE.IN_GAME):
		return
	if(Input.is_action_just_pressed("input_Pause")):
		pauseMenu.show()
		gameVariables.playPosition = gameVariables.bgmPlayer.get_playback_position()
		gameVariables.bgmPlayer.stop()
		get_tree().set_deferred("paused", true)
		gameVariables.MoveToButton(pauseMenu.continuar)
#-------------------------------------------------------------------------------
func PauseOff():
	pauseMenu.hide()
	myPLAY_STATE = PLAY_STATE.IN_GAME
	get_tree().set_deferred("paused", false)
	gameVariables.bgmPlayer.play(gameVariables.playPosition)
#endregion
#-------------------------------------------------------------------------------
#region PLAYER BULLET FUNCTIONS
func CreateDisabledPlayerBullets(_num:int):
	for _i in _num:
		var _bullet: Sprite2D = enemyBullet_Prefab.instantiate() as Bullet
		playerBulletsDisabled.push_back(_bullet)
		_bullet.hide()
		content.add_child(_bullet)
#-------------------------------------------------------------------------------
func PlayerShoot() -> void:
	while(player != null and myPLAY_STATE == PLAY_STATE.IN_GAME):
		if(Input.is_action_pressed("input_Shoot")):
			PlayerShoot1(player.position.x-8, player.position.y-16, 8, -90)
			PlayerShoot1(player.position.x-24, player.position.y-8, 8, -90)
			PlayerShoot1(player.position.x+8, player.position.y-16, 8, -90)
			PlayerShoot1(player.position.x+24, player.position.y-8, 8, -90)
			await Frame(5)
		else:
			await frame
#-------------------------------------------------------------------------------
func PlayerShoot1(_x:float, _y:float, _vel:float, _dir:float) -> void:
	var _bullet = CreatePlayerBullet(_x, _y, _vel, _dir)
	while(_bullet != null):
		if(minX <= _bullet.position.x and _bullet.position.x <= maxX):
			if(minY <= _bullet.position.y and _bullet.position.y <= maxY):
				var _result: Array[Dictionary] = Colliding(_bullet, enemyLayer)
				if(_result):
					ShootedEnemy(_result[0]["collider"])
					DestroyPlayerBullet(_bullet)
					break
				var _dir2: float = deg_to_rad(_bullet.dir)
				_bullet.position += Vector2(_bullet.vel*cos(_dir2), _bullet.vel*sin(_dir2))
				await frame
			else:
				DestroyPlayerBullet(_bullet)
				break
		else:
			DestroyPlayerBullet(_bullet)
			break
#-------------------------------------------------------------------------------
func CreatePlayerBullet(_x:float, _y:float, _vel:float, _dir:float) -> Sprite2D:
	var _bullet : Sprite2D
	if(playerBulletsDisabled.size()>0):
		_bullet = playerBulletsDisabled[0]
		playerBulletsDisabled.erase(_bullet)
		_bullet.show()
	else:
		_bullet = enemyBullet_Prefab.instantiate() as Bullet
		content.add_child(_bullet)
	playerBulletsEnabled.push_back(_bullet)
	_bullet.position = Vector2(_x, _y)
	_bullet.rotation = deg_to_rad(_dir + 90.0)
	_bullet.vel = _vel
	_bullet.dir = _dir
	LeftLabelText()
	return _bullet
#-------------------------------------------------------------------------------
func DestroyPlayerBullet(_obj:Sprite2D) -> void:
	_obj.hide()
	_obj.position = Vector2.ZERO
	playerBulletsEnabled.erase(_obj)
	playerBulletsDisabled.push_back(_obj)
	LeftLabelText()
#-------------------------------------------------------------------------------
func ShootedEnemy(_target:StaticBody2D) -> void:
	if(!_target.canBeHit):
		return
	if(_target.hp>0):
		_target.hp-=1
		SetHp(_target)
	else:
		_target.canBeHit = false
		SpawnItems(_target.position.x, _target.position.y, 20.0, 4)
		SpawnItems(_target.position.x, _target.position.y, 20.0, 4)
		SpawnItems(_target.position.x, _target.position.y, 20.0, 8)
		DestroyEnemy(_target)
#endregion
#-------------------------------------------------------------------------------
#region UI FINCTIONS
func SetGameLimits() -> void:
	height = window.size.y
	unitY = height/10
	width = window.size.x
	unitX = width/10
	centerX = width/2.0
	maxX = centerX+width/2.0
	minX = centerX-width/2.0
	centerY = height/2.0
	maxY = height
	minY = 0.0
#-------------------------------------------------------------------------------
func CenterX(_f:float) -> float:
	var _x: float = centerX+centerX*_f
	return _x
#-------------------------------------------------------------------------------
func CenterY(_f:float) -> float:
	var _y: float = centerY+centerY*_f
	return _y
#-------------------------------------------------------------------------------
func LeftLabelText() -> void:
	var _s: String = ""
	_s += "Enemy Bullets Enabled: " + str(enemyBulletsEnabled.size())+"\n"
	_s += "Enemy Bullets Disabled: " + str(enemyBulletsDisabled.size())+"\n"
	_s += "Player Bullets Enabled: " + str(playerBulletsEnabled.size())+"\n"
	_s += "Player Bullets Disabled: " + str(playerBulletsDisabled.size())+"\n"
	_s += "Items Enabled: " + str(itemsEnabled.size())+"\n"
	_s += "Items Disabled: " + str(itemsDisabled.size())+"\n"
	_s += ""
	leftLabel.text = _s
#-------------------------------------------------------------------------------
func SetScore() -> void:
	var _s: String = str(scorePoints).pad_zeros(9)
	_s = _s.insert(_s.length()-3,",")
	_s = _s.insert(_s.length()-7,",")
	scoreLabel_Num.text = "[center]"+_s+"[/center]"
#-------------------------------------------------------------------------------
func SetLife() -> void:
	livesLabel_Num.text = SetLifePower(lifePoints, player.maxLives)
#-------------------------------------------------------------------------------
func SetPower() -> void:
	powerLabel_Num.text = SetLifePower(powerPoints, player.maxPower)
#-------------------------------------------------------------------------------
func SetLifePower(_point:int, _maxPoint:int) -> String:
	var _s: String = "[center]"+str(_point).pad_zeros(2)+" / "+str(_maxPoint).pad_zeros(2)+"[/center]"
	return _s
#-------------------------------------------------------------------------------
func SetMoney() -> void:
	moneyLabel_Num.text = "[center]"+str(moneyPoints)+" G[/center]"
	#-------------------------------------------------------------------------------
func SetMaxMoney() -> void:
	maxMoneyLabel_Num.text = "[center]"+str(9999)+" G[/center]"
#endregion
#-------------------------------------------------------------------------------
#region ITEM FUNCTIONS
func SpawnItems(_x:float, _y:float, _rad:float, _num:int) -> void:
	for _i in _num:
		var _x2:float = _x + randf_range(-_rad,_rad)
		var _y2:float = _y + randf_range(-_rad,_rad)
		SpawnItem(_x2, _y2)
#-------------------------------------------------------------------------------
func SpawnItem(_x:float, _y:float) -> void:
	var _item: Item = CreateItem(_x, _y)
	var _maxVelY: float = 3.0
	var _magnetVel: float = 8.0
	while(_item != null):
		match(_item.myITEM_STATE):
			ITEM_STATE.FREED:
				if(_item.position.y <= maxY):
					if(_item.velY > _maxVelY):
						_item.velY = _maxVelY
					elif(_item.velY < _maxVelY):
						_item.velY += 0.05
					var _result: Array[Dictionary] = Colliding(_item, magnetLayer)
					if(_result or myPLAY_STATE != PLAY_STATE.IN_GAME):
						_item.myITEM_STATE = ITEM_STATE.IMANTED
					else:
						_item.position.y += _item.velY
				else:
					DestroyItem(_item)
					break
			ITEM_STATE.IMANTED:
				var _vel: Vector2 = (player.position - _item.position)
				if(_vel.length_squared() > 144.0):
					#_item.position += _vel * 0.1
					var _dir = atan2(_vel.y, _vel.x)
					var _vel2 = Vector2(_magnetVel * cos(_dir), _magnetVel * sin(_dir))
					_item.position += _vel2
				else:
					scorePoints += 10
					moneyPoints += 1
					SetScore()
					SetMoney()
					LeftLabelText()
					DestroyItem(_item)
					break
		await frame
#-------------------------------------------------------------------------------
func CreateDisabledItem(_num:int):
	for _i in _num:
		var _item: Sprite2D = item_Prefab.instantiate() as Item
		itemsDisabled.push_back(_item)
		_item.hide()
		content.add_child(_item)
#-------------------------------------------------------------------------------
func CreateItem(_x:float, _y:float) -> Item:
	var _item : Sprite2D
	if(itemsDisabled.size()>0):
		_item = itemsDisabled[0]
		itemsDisabled.erase(_item)
		_item.show()
	else:
		_item = item_Prefab.instantiate() as Item
		content.add_child(_item)
	itemsEnabled.push_back(_item)
	_x = clamp(_x, minX, maxX)
	_item.position = Vector2(_x, _y)
	_item.velY = -2.0
	_item.myITEM_STATE = ITEM_STATE.FREED
	LeftLabelText()
	return _item
#-------------------------------------------------------------------------------
func DestroyItem(_item:Sprite2D) -> void:
	_item.hide()
	_item.position = Vector2.ZERO
	itemsEnabled.erase(_item)
	itemsDisabled.push_back(_item)
	LeftLabelText()
#endregion
#-------------------------------------------------------------------------------
#region START FUNCTIONS
func BeginGame() -> void:
	SetGameLimits()
	#-------------------------------------------------------------------------------
	CreateDisabledItem(200)
	CreateDisabledPlayerBullets(50)
	CreateDisabledEnemyBullets(5000)
	#-------------------------------------------------------------------------------
	SetScore()
	SetMoney()
	SetMaxMoney()
	SetLife()
	SetPower()
	LeftLabelText()
	#-------------------------------------------------------------------------------
	completedPanel.hide()
	completedLabel.text = ""
	timerLabel.text = ""
	#-------------------------------------------------------------------------------
	PlayerShoot()
	Choreography()
#-------------------------------------------------------------------------------
func Choreography() -> void:
	match(gameVariables.currentSaveData.stageIndex):
		0:
			await Stage1()
		1:
			await Stage2()
		2:
			await Stage3()
		3:
			await Stage4()
		4:
			await Stage5()
		5:
			await Stage6()
		6:
			await Stage7()
		7:
			await Stage8()
		8:
			await Stage9()
#endregion
#-------------------------------------------------------------------------------
#region STAGE 1
func Stage1() -> void:
	#await StageCommon("Stage 1 Completed",1,0)
	await WaveOfEnemies_and_Market("Wave of Enemies N°1", Stage1_Wave1, 5)
	await WaveOfEnemies_and_Market("Wave of Enemies N°2", Stage1_Wave3, 10)
	await StageCommon("Stage 1 Completed",1,0)
#-------------------------------------------------------------------------------
func Stage1_Wave1():
	for _j in 2:
		for _i in 4:
			Stage1_Enemy1(unitX*_i*0.75, maxY, -1)
			await Frame2(15)
			Stage1_Enemy1(width-unitX*_i*0.75, maxY, 1)
			await Frame2(15)
#-------------------------------------------------------------------------------
func Stage1_Enemy1(_x:float, _y:float, _mirror:float) -> void:
	if(myPLAY_STATE != PLAY_STATE.IN_GAME):
		return
	#-------------------------------------------------------------------------------
	var _enemy: Enemy = CreateEnemy(_x, _y, 5)
	await MoveTowards(_enemy, _x-unitX*_mirror, CenterY(-0.8), 60)
	await Frame2(60)
	await Stage1_Enemy1_Fire(_enemy, 5)
	await Frame2(60)
	await MoveTowards(_enemy, CenterX(-1*_mirror), CenterY(-0.4), 60)
	DestroyEnemy(_enemy)
#-------------------------------------------------------------------------------
func Stage1_Enemy1_Fire(_enemy, _num:int) -> void:
	var _dir: float
	var _cone: float = 20
	for _i in 3:
		if(_enemy == null or myPLAY_STATE != PLAY_STATE.IN_GAME):
			return
		#-------------------------------------------------------------------------------
		_dir = -_cone/2
		for _j in _num:
			var _bullet: Sprite2D = CreateShotA1(_enemy.position.x, _enemy.position.y, 4, AngleToPlayer(_enemy)+_dir)
			Move_V_Des(_bullet, 0.04, 1)
			_dir += _cone/float(_num-1)
		await Frame(15)
#-------------------------------------------------------------------------------
func Stage1_Enemy2(_x:float, _y:float, _mirror:float) -> void:
	var _enemy: Enemy = CreateEnemy(_x, _y, 5)
	Set_VDir(_enemy, 5, 90+90*_mirror)
	await Move_V_Des(_enemy, 0.05, 1)
	await Move_VDir(_enemy, 60)
	await Stage1_Enemy1_Fire(_enemy, 36)
	await Move_Dir_Rot(_enemy, 6*_mirror, 30)
	await Move_VDir(_enemy, 15)
	await Move_V_Acc(_enemy, 0.05, 5)
	await Move_VDir(_enemy, 60)
	DestroyEnemy(_enemy)
#-------------------------------------------------------------------------------
func Stage1_Wave3():
	var _radX: float = unitX*2.5
	var _rotX: float = 190
	var _x2: float = 0
	for _i in 20:
		if(myPLAY_STATE != PLAY_STATE.IN_GAME):
			return
		#-------------------------------------------------------------------------------
		_rotX += 20
		_x2 = centerX+_radX*sin(deg_to_rad(_rotX))
		Stage1_Enemy3(_x2, minY, -1)
		await Frame(15)
#-------------------------------------------------------------------------------
func Stage1_Enemy3(_x:float, _y:float, _mirror:float) -> void:
	var _enemy: Enemy = CreateEnemy(_x, _y, 25)
	var _radX: float = unitX*2.5
	var _rotX: float = 90+90*_mirror
	var _x2: float = 0
	while(_enemy != null):
		if(_y < maxY and myPLAY_STATE == PLAY_STATE.IN_GAME):
			_rotX += 4
			_x2 = _x+_radX*sin(deg_to_rad(_rotX))
			_y += 1
			_enemy.position = Vector2(_x2, _y)
		else:
			DestroyEnemy(_enemy)
			return
		await frame
#endregion
#-------------------------------------------------------------------------------
#region STAGE 2
func Stage2():
	await StageCommon("Stage 2 Completed",2,1)
#-------------------------------------------------------------------------------
func Stage3():
	await StageCommon("Stage 3 Completed",3,2)
#-------------------------------------------------------------------------------
func Stage4():
	await StageCommon("Stage 4 Completed",4,3)
#-------------------------------------------------------------------------------
func Stage5():
	await StageCommon("Stage 5 Completed",5,4)
#-------------------------------------------------------------------------------
func Stage6():
	await StageCommon("Stage Final Completed",6,5)
#-------------------------------------------------------------------------------
func Stage7():
	await StageCommon("Stage Extra Completed",7,6)
#-------------------------------------------------------------------------------
func Stage8():
	await StageCommon("Rogue-Like Mode Completed",8,7)
#-------------------------------------------------------------------------------
func Stage9():
	await StageCommon("Boss-Rush Mode Completed",8,8)
#-------------------------------------------------------------------------------
func StageCommon(_s:String, _enabled:int, _completed:int):
	await Frame(90)
	completedPanel.show()
	completedLabel.text = _s
	await Frame(90)
	EnableStage(_enabled)
	CompletedStage(_completed)
	gameVariables.Save_SaveData(gameVariables.currentSaveData,gameVariables.optionMenu.optionSaveData.saveIndex)
	gameVariables.CommonSubmited()
	GoToMainScene()
#-------------------------------------------------------------------------------
func EnableStage(_i:int):
	var _player: int = gameVariables.currentSaveData.playerIndex
	var _difficulty: int = gameVariables.currentSaveData.difficultyIndex
	if(gameVariables.currentSaveData.player[_player].difficulty[_difficulty].stage[_i].mySTAGE_STATE == StageSaveData.STAGE_STATE.DISABLED):
		gameVariables.currentSaveData.player[_player].difficulty[_difficulty].stage[_i].mySTAGE_STATE = StageSaveData.STAGE_STATE.ENABLED
#-------------------------------------------------------------------------------
func CompletedStage(_i:int):
	var _player: int = gameVariables.currentSaveData.playerIndex
	var _difficulty: int = gameVariables.currentSaveData.difficultyIndex
	gameVariables.currentSaveData.player[_player].difficulty[_difficulty].stage[_i].mySTAGE_STATE = StageSaveData.STAGE_STATE.COMPLETED
#-------------------------------------------------------------------------------
func GoToMainScene():
	gameVariables.PlayBGM(gameVariables.bgmTitle)
	get_tree().set_deferred("paused", false)
	get_tree().change_scene_to_file(gameVariables.mainScene_Path)
#endregion
#-------------------------------------------------------------------------------
#region STAGE FUNCTIONS
func WaveOfEnemies_and_Market(_s:String, _c:Callable, _time:int):
	await ShowBanner(_s)
	_c.call()
	StartTimer(_time)
	await endMoment
	OpenMarket()
	await endMoment
#-------------------------------------------------------------------------------
func StartTimer(_time:int):
	var _maxTimer: String = "s / "+str(_time)+"s"
	_time+=1
	while(_time > 0):
		_time -=1
		timerLabel.text = str(_time)+_maxTimer
		await Frame(60)
	timerLabel.text = ""
	myPLAY_STATE = PLAY_STATE.IN_MARKET
	endMoment.emit()
#-------------------------------------------------------------------------------
func ShowBanner(_s:String):
	completedPanel.show()
	completedLabel.text = _s
	await Frame(90)
	completedPanel.hide()
	completedLabel.text = "_s"
#-------------------------------------------------------------------------------
func OpenMarket():
	marketMenu.show()
	gameVariables.MoveToButton(marketMenu.close)
	#NOTA: Por alguna razon el boton no se alinea con el container la primera vez, hay que ayudarlo
	marketMenu.scrollContainer.scroll_horizontal = 0
#endregion
#-------------------------------------------------------------------------------
#region ENEMY FUNCTIONS
func CreateEnemy(_x:float, _y:float, _hp: int) -> Enemy:
	var _enemy = enemy_Prefab.instantiate() as Enemy
	_enemy.position = Vector2(_x, _y)
	_enemy.maxHp = _hp
	_enemy.hp = _hp
	SetHp(_enemy)
	content.add_child(_enemy)
	return _enemy
#-------------------------------------------------------------------------------
func SetHp(_target:StaticBody2D) -> void:
	_target.label.text = str(_target.hp)+"/"+str(_target.maxHp)+" HP"
#-------------------------------------------------------------------------------
func DestroyEnemy(_enemy) -> void:
	if(_enemy != null):
		_enemy.queue_free()
#endregion
#-------------------------------------------------------------------------------
#region ENEMY BULLET FUNCTIONS
func CreateDisabledEnemyBullets(_num:int):
	for _i in _num:
		var _bullet: Sprite2D = enemyBullet_Prefab.instantiate() as Bullet
		enemyBulletsDisabled.push_back(_bullet)
		_bullet.hide()
		content.add_child(_bullet)
#-------------------------------------------------------------------------------
func CreateEnemyBullet(_x:float, _y:float, _vel:float, _dir:float) -> Bullet:
	var _bullet: Bullet
	if(enemyBulletsDisabled.size()>0):
		_bullet = enemyBulletsDisabled[0]
		enemyBulletsDisabled.erase(_bullet)
		_bullet.show()
	else:
		_bullet = enemyBullet_Prefab.instantiate() as Bullet
		content.add_child(_bullet)
	enemyBulletsEnabled.push_back(_bullet)
	_bullet.position = Vector2(_x, _y)
	_bullet.rotation = deg_to_rad(_dir + 90.0)
	_bullet.vel = _vel
	_bullet.dir = _dir
	LeftLabelText()
	return _bullet
#-------------------------------------------------------------------------------
func CreateShotA1(_x:float, _y:float, _vel:float, _dir:float) -> Sprite2D:
	var _bullet: Sprite2D = CreateEnemyBullet(_x, _y, _vel, _dir)
	CommonEnemyBulletFunction(_bullet)
	return _bullet
#-------------------------------------------------------------------------------
func CommonEnemyBulletFunction(_bullet) -> void:
	while(_bullet != null):
		if(minX <= _bullet.position.x and _bullet.position.x <= maxX):
			if(minY <= _bullet.position.y and _bullet.position.y <= maxY):
				if(myPLAY_STATE == PLAY_STATE.IN_GAME):
					var _result: Array[Dictionary] = Colliding(_bullet, playerLayer)
					if(_result):
						ShootedPlayer(_result[0]["collider"])
						DestroyEnemyBullet(_bullet)
						break
					var _dir2: float = deg_to_rad(_bullet.dir)
					_bullet.position += Vector2(_bullet.vel*cos(_dir2), _bullet.vel*sin(_dir2))
					await frame
				else:
					DestroyEnemyBullet(_bullet)
					break
			else:
				DestroyEnemyBullet(_bullet)
				break
		else:
			DestroyEnemyBullet(_bullet)
			break
#-------------------------------------------------------------------------------
func DestroyEnemyBullet(_obj:Bullet) -> void:
	_obj.hide()
	_obj.position = Vector2.ZERO
	enemyBulletsEnabled.erase(_obj)
	enemyBulletsDisabled.push_back(_obj)
	LeftLabelText()
#-------------------------------------------------------------------------------
func ShootedPlayer(_target:StaticBody2D) -> void:
	lifePoints -= 1
	SetLife()
#endregion
#-------------------------------------------------------------------------------
#region MOVEMENT FUNCTIONS
func MoveTowards(_enemy, _x:float, _y:float,_timer:int) -> void:
	if(_enemy == null or myPLAY_STATE!= PLAY_STATE.IN_GAME):
		return
	var _dx: float = (_x-_enemy.position.x)/float(_timer)
	var _dy: float = (_y-_enemy.position.y)/float(_timer)
	for _i in _timer:
		if(_enemy == null or myPLAY_STATE!= PLAY_STATE.IN_GAME):
			return
		_enemy.position += Vector2(_dx, _dy)
		await frame
#-------------------------------------------------------------------------------
func Set_VDir(_enemy, _vel:float, _dir:float) -> void:
	if(_enemy == null):
		return
	_enemy.vel = _vel
	_enemy.dir = _dir
	Common_VDir(_enemy)
#-------------------------------------------------------------------------------
func Move_VDir(_enemy, _timer:int) -> void:
	for _i in _timer:
		if(_enemy == null):
			break
		_enemy.position += Vector2(_enemy.velX, _enemy.velY)
		await frame
#-------------------------------------------------------------------------------
func Move_V_Des(_enemy, _velDess:float, _velMin:float) -> void:
	while(_enemy != null):
		if(_enemy.vel < _velMin):
			_enemy.vel = _velMin
			Common_VDir(_enemy)
			_enemy.position += Vector2(_enemy.velX, _enemy.velY)
			break
		else:
			_enemy.vel -= abs(_velDess)
			Common_VDir(_enemy)
			_enemy.position += Vector2(_enemy.velX, _enemy.velY)
		await frame
#-------------------------------------------------------------------------------
func Move_V_Acc(_enemy, _velAccel:float, _velMax:float) -> void:
	while(_enemy != null):
		if(_enemy.vel > _velMax):
			_enemy.vel = _velMax
			Common_VDir(_enemy)
			_enemy.position += Vector2(_enemy.velX, _enemy.velY)
			break
		else:
			_enemy.vel += abs(_velAccel)
			Common_VDir(_enemy)
			_enemy.position += Vector2(_enemy.velX, _enemy.velY)
		await frame
#-------------------------------------------------------------------------------
func Move_Dir_Rot(_enemy, _dirAccel:float, _timer:int) -> void:
	for _i in _timer:
		if(_enemy == null):
			break
		_enemy.dir += _dirAccel
		Common_VDir(_enemy)
		_enemy.position += Vector2(_enemy.velX, _enemy.velY)
		await frame
#-------------------------------------------------------------------------------
func Common_VDir(_enemy) -> void:
	var _dir2: float = deg_to_rad(_enemy.dir)
	_enemy.velX = _enemy.vel*cos(_dir2)
	_enemy.velY = _enemy.vel*sin(_dir2)
#endregion
#-------------------------------------------------------------------------------
#region MATH FUNCTIONS
func AngleToPlayer(_obj: Node2D) -> float:
	var _f: float = rad_to_deg(atan2(player.position.y-_obj.position.y, player.position.x-_obj.position.x))
	return _f
#endregion
#-------------------------------------------------------------------------------
#region COMMON FUNCTIONS
func Colliding(_sprite:Sprite2D, _layer) -> Array[Dictionary]:
	var _shape_rid :RID = PhysicsServer2D.rectangle_shape_create()
	var _half_extents :Vector2 = _sprite.size
	PhysicsServer2D.shape_set_data(_shape_rid, _half_extents)
	#-------------------------------------------------------------------------------
	var _query :PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	_query.shape_rid = _shape_rid
	_query.collide_with_bodies = true
	_query.collision_mask = _layer
	_query.transform = _sprite.get_global_transform()
	#-------------------------------------------------------------------------------
	#var _direct_space_state :PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var _result :Array[Dictionary] = _direct_space_state.intersect_shape(_query, 1)
	#-------------------------------------------------------------------------------
	PhysicsServer2D.free_rid(_shape_rid)
	return _result
#-------------------------------------------------------------------------------
func Frame(_timer:int) -> void:
	for _i in _timer:
		await frame
#-------------------------------------------------------------------------------
func Frame2(_timer:int) -> void:
	for _i in _timer:
		if(myPLAY_STATE != PLAY_STATE.IN_GAME):
			return
		await frame
#endregion
#-------------------------------------------------------------------------------
#region IDIOME FUNCTIONS
func SetIdiome():
	gameVariables.DisconnectAll(gameVariables.optionMenu.idiomeChange)
	#-------------------------------------------------------------------------------
	gameVariables.optionMenu.idiomeChange.connect(pauseMenu.SetIdiome)
	gameVariables.optionMenu.idiomeChange.connect(SetIdiome2)
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
