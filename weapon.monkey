Strict

Import vector
Import mojo
Import managers
Import globals

Class Weapon

	Field direction:Vector

	Field position:Vector
	Field rotation:Float
	Field image:GameImage
	Field frame:Int
	
	Field cooldown:Float
	Field elapsedSinceFired:Float
	
	Field projectile:Projectile

	Field fireSound:GameSound
	
	Method New(startingPosition:Vector)
	
		position = startingPosition
		direction = New Vector(0,0)

		image = gGame.images.Find("WeaponBlue") 

		fireSound = gGame.sounds.Find("shoot")

		projectile = New Projectile()
		projectile.speed = 4
		projectile.damage = 2

		cooldown = 750
		elapsedSinceFired = 0
	End
	
	Method OnUpdate:Void()
		elapsedSinceFired = elapsedSinceFired + gGame.dt.frametime
	End

	Method OnRender:Void()
		If image Then
			DrawImage(image.image, position.X, position.Y - 10, 0, 1, 1, frame)
			
		End
	End
	
	Method Fire:Void()
		'Check to make sure that we can fire
		If elapsedSinceFired > cooldown Then
			elapsedSinceFired = 0
			
			Local delta:Vector = direction.Scale(40)
			delta.AddLocal(position)
			delta.Y = delta.Y - 10
			gProjectileManager.AddProjectile(projectile.Clone(delta, direction, rotation))
			fireSound.Play()
		End
				
	End
	
	' FixAim will take in a direction vector instead of the location
	' of the mouse.   From this we will compute the rotation and update
	' the correct frame of the top of the tank.
	Method FixAim:Void(v:Vector)
		'Print "FixAim: " + v.X + " .. " + v.Y + " --- " + direction.Length()
		direction.Set(v.X, v.Y)
		rotation = ATan2(direction.Y, direction.X)
		
		If rotation > 360 Then
			rotation -= 360
		End
		
		If rotation < 0 Then
			rotation += 360
		End
		
		'Update frame #
		If rotation < 11.25
			frame = 0
		Else If rotation < 33.75
			frame = 1
		Else If rotation < 56.25
			frame = 2
		Else If rotation < 78.75
			frame = 3
		Else If rotation < 101.25
			frame = 4
		Else If rotation < 123.75
			frame = 5
		Else If rotation < 146.25
			frame = 6
		Else If rotation < 168.75
			frame = 7
		Else If rotation < 191.25
			frame = 8
		Else If rotation < 213.75
			frame = 9
		Else If rotation < 236.25
			frame = 10
		Else If rotation < 256.75
			frame = 11
		Else If rotation < 281.25
			frame = 12
		Else If rotation < 303.75
			frame = 13
		Else If rotation < 326.25
			frame = 14
		Else If rotation < 348.75
			frame = 15
		Else
			frame = 0
		End

	End
	
	Method AimAt:Void(v:Vector)
		Local dir:Vector = v.Subtract(position)
		dir.Normalize()
		
		FixAim(dir)
	End

End