
Import itanks
Import globals
Import vector
Import thumbstick

' This method will allow us to save out preferences
' If the user prefers accelerometer then we will write that
' out and when we read it back in, we can construct the appropriate
' type of player input.
Function CreatePlayerInput:PlayerInput(name:String)
	If name = KEYBOARD Then
		Return New KeyboardInput()
	End
	
	If name = THUMBSTICK Then
		Return New ThumbstickInput()
	End
	
	If name = CONTROLLER Then
		Return New ControllerInput()
	End
	
	If name = ACCELEROMETER Then
		Return New AccelerometerInput()
	End
	
	Error "Unknown input type!"
End

'************************************************************
Class PlayerInput
	Field name:String
	Field tank:Tank
	
	'--------------------------------------------------------
	Method Update:Void(clickConsumed:Bool)
		Error "Should never call PlayerInput.Update().... Instead call this method on the subclasses"
	End
	
	'--------------------------------------------------------
	Method Render:Void()
		' override if you need to render anything	
	End
	
	' Methods below here are mainly here for the Android and iOS devices
	' since they will allow a user to have to different types of input
	' by default they do nothing, but the thumbstick input will
	' override their behavior and pass the relevant information on 
	' to each individual thumbstick.
	
	'--------------------------------------------------------
	Method OnTouchHit:Void(x:Int, y:Int, pointer:Int)

	End
	
	'--------------------------------------------------------
	Method OnTouchReleased:Void(x:Int, y:Int, pointer:Int)

	End
	
	'--------------------------------------------------------
	Method OnTouchDragged:Void(x:Int, y:Int, dx:Int, dy:Int, pointer:Int)

	End
	
	'--------------------------------------------------------
	Method OnTouchClick:Void(x:Int, y:Int, pointer:Int)

	End
  
	'--------------------------------------------------------
	Method OnTouchLongPress:Void(x:Int, y:Int, pointer:Int)

	End

	'--------------------------------------------------------
	Method OnTouchFling:Void(releaseX:Int, releaseY:Int, velocityX:Float, velocityY:Float, velocitySpeed:Float, pointer:Int)

	End
End

'************************************************************
Class KeyboardInput Extends PlayerInput
	Field mousePosition:Vector

	'--------------------------------------------------------
	Method New()
		name = KEYBOARD
		mousePosition = New Vector(0,0)
	End

	'--------------------------------------------------------
	Method Update:Void(clickConsumed:Bool)
		tank.forward = KeyDown(KEY_W) = 1
		tank.backward = KeyDown(KEY_S) = 1
		tank.left = KeyDown(KEY_A) = 1
		tank.right = KeyDown(KEY_D) = 1

		mousePosition.X = game.mouseX
		mousePosition.Y = game.mouseY
		tank.weapon.AimAt(mousePosition)

		If MouseHit(MOUSE_LEFT) = 1 And Not clickConsumed  Then
			tank.weapon.Fire()
		End
	End

End

'************************************************************
Class ThumbstickInput Extends PlayerInput
	Field move:Thumbstick
	Field shoot:Thumbstick

	'--------------------------------------------------------
	Method New()
		name = THUMBSTICK
		move = New Thumbstick(110, 530);
		shoot = New Thumbstick(850, 530);

		'test thumbsticks
		move.isActive = True;
		shoot.isActive = True;
	End

	'--------------------------------------------------------
	Method Update:Void(clickConsumed:Bool)
'        Right now this code works on the iPhone debugger, but probably
'        will not work on the phone itself since it doesn't keep track of the
'        finger id and we hardcode you to the 0 th pointer always.

		#If TARGET="ios" Or TARGET="android"
			If MouseHit(MOUSE_LEFT) = 1 And Not clickConsumed Then			
				RegisterThumbsticks(game.mouseX, game.mouseY, 0)
			End If
		
			If MouseDown(MOUSE_LEFT) = 1
				UpdateThumbsticks(game.mouseX, game.mouseY, 0)			
			End If
		
			If MouseDown(MOUSE_LEFT) = 0
				UnregisterThumbsticks(0)
			End If
		#End
	End
	
	'--------------------------------------------------------
	Method Render:Void()
		move.Render();
		shoot.Render();
	End
	
	
	'--------------------------------------------------------
	Method OnTouchHit:Void(x:Int, y:Int, pointer:Int)
		Print "OnTouchHit: " + x + " " + y + " " + pointer
		RegisterThumbsticks(x, y, pointer)
	End
	
	'--------------------------------------------------------
	Method OnTouchReleased:Void(x:Int, y:Int, pointer:Int)
		' fired when you release a finger from the screen
		Print "OnTouchReleased: " + x + " " + y + " " + pointer
		UnregisterThumbsticks(pointer)
	End
	
	'--------------------------------------------------------
	Method OnTouchDragged:Void(x:Int, y:Int, dx:Int, dy:Int, pointer:Int)
		' fired when one of your fingers drags along the screen
		Print "OnTouchDragged: " + x + " " + y + " " + pointer
		UpdateThumbsticks(x, y, pointer)
	End
	
	'--------------------------------------------------------
	Method OnTouchClick:Void(x:Int, y:Int, pointer:Int)
		Print "OnTouchClick: " + x + " " + y + " " + pointer
	End
  
	'--------------------------------------------------------
	Method OnTouchLongPress:Void(x:Int, y:Int, pointer:Int)
		' fired if you touch the screen and hold the finger in the same position for one second (configurable using game.inputCache.LongPressTime)
		' this is checked at a specific time after touching the screen, so if you move your finger around and then
		' hold it still, it won't fire
		Print "OnTouchLongPress: " + x + " " + y + " " + pointer
	End

	'--------------------------------------------------------
	Method OnTouchFling:Void(releaseX:Int, releaseY:Int, velocityX:Float, velocityY:Float, velocitySpeed:Float, pointer:Int)
		' fired after you release a finger from the screen, if it was moving fast enough (configurable using game.inputCache.FlingThreshold)
		' velocityx/y/speed is in pixels per second, but speed is taken from the entire vector, by pythagoras
		' ie. velocitySpeed = Sqrt(velocityX*velocityX + velocityY*velocityY) in pixels per second
		Print "OnTouchFling"
	End

	
	'--------------------------------------------------------
	Method RegisterThumbsticks(x:Int, y:Int, index:Int)
		If move.isActive
			move.Register(x, y, index)
		End
		
		If shoot.isActive
			shoot.Register(x, y, index)
		End
	End
			
	'--------------------------------------------------------
	Method UnregisterThumbsticks(index:Int)
		If move.registeredIndex = index
			move.Unregister()
		End
				
		If shoot.registeredIndex = index
			shoot.Unregister()
		End
	End
		
	'--------------------------------------------------------
	Method UpdateThumbsticks(x:Int, y:Int, index:Int)
		If move.isActive And move.registeredIndex = index
			move.Update(x, y)
			tank.DirectionalMove(move.normal)
		End
		
		If shoot.isActive And shoot.registeredIndex = index
			shoot.Update(x, y)
			
			tank.weapon.FixAim(shoot.normal)
			If Not shoot.inside
				'should not fire without setting where we want to shoot
				tank.weapon.Fire()
			End
		End
	End
	


End

'************************************************************
Class ControllerInput Extends PlayerInput

End

'************************************************************
Class AccelerometerInput Extends PlayerInput

End