
Import diddy
Import projectile

Class ProjectileManager

	Field projectiles:ArrayList<Projectile>

	Method New()
		projectiles = New ArrayList<Projectile>()
	End

	Method OnUpdate:Void()
		For Local i:=0 To projectiles.Size - 1 Step 1
			projectiles.Get(i).OnUpdate()
		Next
	End
	
	Method OnRender:Void()
	 	For Local i:=0 To projectiles.Size - 1 Step 1
			projectiles.Get(i).OnRender()
		Next 
	End
	
	Method AddProjectile:Void(p:Projectile)
		projectiles.Add(p)	
	End

	Method RemoveProjectile:Void(p:Projectile)
		projectiles.Remove(p)
	End
End

