
Import diddy
Import vector
Import mojo

Import globals

Class Projectile
	
	Field position:Vector
	Field velocity:Vector
	Field speed:Float
	Field damage:Float = 1
	Field hasBounced:Bool = False
	Field rotation:Float = 0
	
	Field image:GameImage

	Field bounceSound:GameSound
	Field explosionSound:GameSound
	Field tankExplosionSound:GameSound
	
	Method New()
		image = gGame.images.Find("Projectile")
		explosionSound = gGame.sounds.Find("explosion")
		bounceSound = gGame.sounds.Find("bounce")
		tankExplosionSound = gGame.sounds.Find("tankExplosion")
		
		position = New Vector()
		velocity = New Vector()
	End
	
	Method OnUpdate:Void()
		'First check to see if we are colliding with any tanks since we explode
		'regardless.
		Local tank:Tank = CheckTankCollisions(position)
		If tank <> Null Then
				'remove the projectile from the game world
				gProjectileManager.RemoveProjectile(Self)
				tankExplosionSound.Play()
				tank.Hit(damage)
		Else If CheckCollisions() Then
			If hasBounced Then
				'remove the projectile from the game world
				gProjectileManager.RemoveProjectile(Self)
				explosionSound.Play()
			Else
				bounceSound.Play()	
				hasBounced = True
				
				'we should multiply the velocity vector by the normal
				'of the collision geometry, but since we don't have that
				'we will determine what type of collision it is based on 
				'the current velocity.
				Local reflect:Vector = gWorld.Reflect(position, velocity)
				velocity.Set( velocity.X*reflect.X, velocity.Y*reflect.Y )
			End
		End
		
		position.AddLocal(velocity)		
	End

	Method OnRender:Void()
		If image Then	
			DrawImage(image.image, position.X, position.Y, rotation, 1, 1)
		End
	End

	Method Clone:Projectile(position:Vector, norm:Vector, rot:Float)
		'Print "Spawning Projectile: " + position.X + " " + position.Y
	
		Local clone:Projectile = New Projectile()
		
		clone.position.Set(position.X, position.Y)
		clone.rotation = rot
		clone.velocity.Set(norm.X, norm.Y)
		clone.velocity.ScaleLocal(Self.speed)
		clone.damage = Self.damage
		clone.image = Self.image
		
		Return clone
	End
	
	Method CheckTankCollisions:Tank(p:Vector)
		'Since the collision geometry of the tank will soon
		'be changing, I plan on only checking to see if we are within
		'so many pixels of the tank
		Local tank:Tank 
		For tank = Eachin gTanks
			If tank.health <= 0 Then
				Continue
			End
		
			If tank.position.Subtract(p).Length() < 20 Then
				Return tank
			End
		End
		Return Null
	End
	
	Method CheckCollisions:Bool()
		If gWorld.IsCollision(position) Then
			Return True	
		End
		Return False		
	End

	
	
End