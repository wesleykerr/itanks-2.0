
Import diddy
Import itanks

Import aitank
Import globals
Import tank
Import vector
Import world

'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
Class GameScreen Extends iTanksScreen

	Field input:PlayerInput

	Field state:Stack<GameState>
	
	Field countdown:GameState
	Field running:GameState
	Field gameOver:GameState
	Field paused:GameState
	
	Field movement:Vector
	Field numberOfPlayers:Float = 1
	Field comparator:TankComparator = New TankComparator()
	
	'Still keep a reference to the player's tank
	Field tank:Tank
	
	Field mouseConsumed:Bool
	
	Field zone:Int
	Field level:Int
	
	'----------------------------------------------------------------------
	Method New()
		Super.New()
		
		state = New Stack<GameState>()
		countdown = New CountdownState(Self)
		running = New RunningState(Self)
		gameOver = New GameOverState(Self)
		paused = New PauseState(Self)
				
		AddBackButton(Null)
		' add in the pause button... that will display another menu
		' overtop of the actual game.
		Local pause:GameImage = gGame.images.Find("hudButtons")
		Local pauseBtn:iTanksButton = New iTanksButton(pause, 150, 75, 4, 5)
		pauseBtn.name = "pause".ToUpper()
		menu.AddButton(pauseBtn)
	End
	
	'----------------------------------------------------------------------
	Method Start:Void()
		gGameOver = False
		gWon = False 

		gGame.screenFade.Start(50, False)

		backScreen = gLevelScreens.Get(zone)
		state.Push(countdown)
		state.Top().OnEnter()

		Local levelName:String = "World_" + zone + "_" + level
		Print("Loading..." + levelName)
		gWorld = New World(levelName)
				
		gProjectileManager = New ProjectileManager()
		gTanks = New ArrayList<Tank>()
		
		Local playersToPlace:Int = numberOfPlayers
		
		While gWorld.spawnPoints.Size() > 0
			Local spawn:Int = Rnd(0, gWorld.spawnPoints.Size())
			
			If playersToPlace > 0
				tank = New Tank("Player", gTanks.Size(), gWorld.spawnPoints.Get(spawn).vector)
				tank.rotation = Float(gWorld.spawnPoints.Get(spawn).rotation)
				tank.UpdateRotationFrame()
				gTanks.Add(tank)
				playersToPlace = playersToPlace - 1
			Else
				Local aitank:AITank = New AITank("AI", gTanks.Size(), gWorld.spawnPoints.Get(spawn).vector)
				aitank.rotation = Float(gWorld.spawnPoints.Get(spawn).rotation)
				aitank.UpdateRotationFrame()
				gTanks.Add(aitank)
			End
			
			gWorld.spawnPoints.RemoveAt(spawn)
		End
		
		For Local tank:Tank = Eachin gTanks
			tank.OnPostInit()
		End
		
		input = CreatePlayerInput(gGameSaveState.inputName)
		input.tank = tank
	End
	
	Method PostFadeOut:Void()
		' make sure to call the appropriate cleanup on states.
		For Local s:GameState = Eachin state
			s.OnExit()
		End
		Super.PostFadeOut()	
	End

	'----------------------------------------------------------------------
	Method Render:Void()
		state.Top().Render()
		Super.Render()
	End
	
	'----------------------------------------------------------------------
	Method Update:Void()
		Super.Update()
		mouseConsumed = False
		state.Top().Update()
	End
	
	'----------------------------------------------------------------------
	Method Transition:Void(state:GameState, push:Bool=False)
	
		If Not push Then
			Self.state.Top().OnExit()
			Self.state.Pop()
		Else
			Self.state.Top().OnPaused()
		End		
		
		Self.state.Push(state)
		Self.state.Top().OnEnter()
	End	

	'----------------------------------------------------------------------
	Method PopState:Void()
		Self.state.Top().OnExit()
		Self.state.Pop()
		Self.state.Top().OnResume()
	End		
	
	'----------------------------------------------------------------------
	Method OnTouchHit:Void(x:Int, y:Int, pointer:Int)
		input.OnTouchHit(x, y, pointer)
	End
	
	'----------------------------------------------------------------------
	Method OnTouchReleased:Void(x:Int, y:Int, pointer:Int)
		input.OnTouchReleased(x, y, pointer)
	End
	
	'----------------------------------------------------------------------
	Method OnTouchDragged:Void(x:Int, y:Int, dx:Int, dy:Int, pointer:Int)
		input.OnTouchDragged(x, y, dx, dy, pointer)
	End
	
	'----------------------------------------------------------------------
	Method OnTouchClick:Void(x:Int, y:Int, pointer:Int)
		input.OnTouchClick(x, y, pointer)
	End
  
	'----------------------------------------------------------------------
	Method OnTouchLongPress:Void(x:Int, y:Int, pointer:Int)
		input.OnTouchLongPress(x, y, pointer)
	End

	'----------------------------------------------------------------------
	Method OnTouchFling:Void(releaseX:Int, releaseY:Int, velocityX:Float, velocityY:Float, velocitySpeed:Float, pointer:Int)
		input.OnTouchFling(releaseX, releaseY, velocityX, velocityY, velocitySpeed, pointer)
	End
	
End

'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
Class GameState
	Field screen:GameScreen
	
	Method New(screen:GameScreen)
		Self.screen = screen
	End
	
	'----------------------------------------------------------------------
	' Override this method to handle any initialization that needs to be done
	' when you enter this state.
	Method OnEnter:Void()
	
	End
	
	'----------------------------------------------------------------------
	' Override this method to handle any cleanup that needs to be done
	' when you leave this state.
	Method OnExit:Void()
	
	End

	'----------------------------------------------------------------------
	' Override this method to do any special things when this state is paused
	Method OnPaused:Void()
	
	End	
	
	'----------------------------------------------------------------------
	' Override this method to do any special things when this state resumes
	Method OnResume:Void()
	
	End	

	'----------------------------------------------------------------------
	'  The default render for the gGame state is to render all of the
	'  objects in the world on the standard background.
	Method Render:Void()
		Cls
		
		SetColor(255, 255, 255)
		DrawRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
		
		gWorld.RenderBackground()		
		If gDebug
			gWorld.RenderGrid()
		End
		gProjectileManager.OnRender()
		
		'render all of the tanks
		gTanks.Sort(False, screen.comparator)
		Local t:Tank
		For t = Eachin gTanks
			t.OnRender()
		End
		
		gWorld.RenderForeground()	
	End
	
	'----------------------------------------------------------------------
	'  The default update for the game state is to update all of the tanks
	'  and the objects in the world.
	Method Update:Void()
		For Local t:Tank = Eachin gTanks
			t.OnUpdate()
		End
		
		gProjectileManager.OnUpdate()		
	End
End

'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
Class CountdownState Extends GameState
	Field countdown:GameImage

	Field elapsed:Float
	Field delay:Float

	Method New(screen:GameScreen)
		Super.New(screen)

		countdown = gGame.images.Find("numbers")
	End
	
	'----------------------------------------------------------------------
	Method OnEnter:Void()
		elapsed = 0
		delay = 4000
	End
	
	'----------------------------------------------------------------------
	Method Render:Void()
		Super.Render()
		screen.input.Render()
		
		'now render all of the countdown information....
		Local index:Int = 3 - Int((delay - elapsed) / 1000);
		If index >= 0 Then
			DrawImage(countdown.image, 480, 320, index)
		End
	End
	
	'----------------------------------------------------------------------
	Method Update:Void()
		If screen.menu.Clicked("pause") Then
			screen.Transition(screen.paused, True)
			Return
		End

		' no update called on the super because we haven't started playing
		' the game yet...
		elapsed = elapsed + gGame.dt.frametime;
			
		If elapsed > delay Then
			screen.Transition(screen.running)
		End
	End
End


'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
Class RunningState Extends GameState

	'----------------------------------------------------------------------
	Method New(screen:GameScreen)
		Super.New(screen)
	End
	
	'----------------------------------------------------------------------
	Method Update:Void()
		If screen.menu.Clicked("pause") Then
			screen.Transition(screen.paused, True)
			Return
		End
	
		' check to see if the game is over and we should
		' leave the running state.
		gAlive = 0
		Local t:Tank
		For t = Eachin gTanks
			If t.health > 0 Then
				gAlive += 1
			End
		End
		
		' Check to see if we have lost this round.  If so then
		' we need to display the losing information... and move on.
		If gAlive = 1 And screen.tank.health > 0 Then
			gGameOver = True
			gWon = True
			screen.Transition(screen.gameOver)
		End
		
		If screen.tank.health <= 0 Then
			gGameOver = True 
			gWon = False 
			screen.Transition(screen.gameOver)
		End

		screen.input.Update(screen.mouseConsumed)	
		Super.Update()
	End
	
	Method Render:Void()
		Super.Render()
		screen.input.Render()
	End
End


'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
Class GameOverState Extends GameState

	Field image:GameImage
	Field btnImages:GameImage

	Field progressionMenu:iTanksMenu

	'----------------------------------------------------------------------
	Method New(screen:GameScreen)
		Super.New(screen)
		
		progressionMenu = New iTanksMenu("ButtonOver", "ButtonClick", True)
		btnImages = gGame.images.Find("progressButtons")
	End
	
	'----------------------------------------------------------------------
	Method OnEnter:Void()
		Local index:Int = 471
		progressionMenu.Clear()
		
		If gWon Then
			gGameSaveState.OnWin(screen.zone, screen.level)
			image = gGame.images.Find("Win")		

			If (screen.zone = 0 And screen.level < 2) Or (screen.zone > 0 And screen.level < LEVEL_COUNT-1) Then
				Local nextBtn:iTanksButton = New iTanksButton(btnImages, 476, 471, 0, 1)
				nextBtn.name = "next".ToUpper()
				progressionMenu.AddButton(nextBtn)
			
				index = 550
			End
		Else
			image = gGame.images.Find("Fail")		
		End
		
		Local backBtn:iTanksButton = New iTanksButton(btnImages, 364, index, 2, 3)
		backBtn.name = "progress-back".ToUpper()
		progressionMenu.AddButton(backBtn)

		Local restartBtn:iTanksButton = New iTanksButton(btnImages, 588, index, 4, 5)
		restartBtn.name = "restart".ToUpper()
		progressionMenu.AddButton(restartBtn)

		For Local btn:iTanksButton = Eachin screen.menu
			btn.active = 0					
		End
	End

	'----------------------------------------------------------------------
	Method OnExit:Void()
		For Local btn:iTanksButton = Eachin screen.menu
			btn.active = 1
		End
	End
	
	'----------------------------------------------------------------------
	Method Update:Void()
		progressionMenu.Update()
		If progressionMenu.Clicked("next") Then
			' we need to determine what the next level will
			' be.
			screen.level += 1
			gGame.screenFade.Start(10, True)
			gGame.nextScreen = screen
		End
		
		If progressionMenu.Clicked("progress-back") Then
			gGame.screenFade.Start(10, True)
			gGame.nextScreen = screen.backScreen
		End

		If progressionMenu.Clicked("restart") Then
			gGame.screenFade.Start(10, True)
			gGame.nextScreen = screen
		End
		
		Super.Update()
	End
	
	'----------------------------------------------------------------------
	Method Render:Void()
		Super.Render()
		
		DrawImage(image.image, 480, 320, 0, 1, 1)
		
		progressionMenu.Draw()
	End

End

'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
Class PauseState Extends GameState
	Field pauseMenu:iTanksMenu

	'----------------------------------------------------------------------
	Method New(screen:GameScreen)
		Super.New(screen)
		
		pauseMenu = New iTanksMenu("ButtonOver", "ButtonClick", True)
	End
	
	'----------------------------------------------------------------------
	Method Update:Void()
		If screen.menu.Clicked("pause") Then
			screen.PopState()
			Return
		End
	End
	
	'----------------------------------------------------------------------
	Method Render:Void()
		Super.Render()
		
		pauseMenu.Draw()	
	End

End

'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////////
Class TankComparator Extends AbstractComparator
	Method Compare:Int(o1:Object, o2:Object) 
		Local t1:Tank= Tank(o1)
		Local t2:Tank= Tank(o2)
		
		If t1.position.Y < t2.position.Y Then Return -1
		If t1.position.Y > t2.position.Y Then Return 1
		Return 0
	End
End