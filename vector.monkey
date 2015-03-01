Strict

Class Vector

	Field X:Float
	Field Y:Float
	
	Method New(x:Float, y:Float)
		X = x
		Y = y
	End
	
	Method Set:Void (x:Float, y:Float)
		X = x
		Y = y
	End
	
	Method Normalize:Void()
		Local length:Float = Length()
		
		If length > 0
			X /= length
			Y /= length
		End
	End
	
	Method AddLocal:Void(x:Float, y:Float)
		X += x
		Y += y
	End
	
	Method AddLocal:Void(v:Vector)
		X += v.X
		Y += v.Y
	End
	
	Method Add:Vector(x:Float, y:Float)
		Return New Vector(Self.X + x, Self.Y + y)
	End
	
	Method Add:Vector(v:Vector)
		Return New Vector(X + v.X, Y + v.Y)
	End
	
	Method SubtractLocal:Void(v:Vector)
		X -= v.X
		Y -= v.Y
	End
	
	Method Subtract:Vector(v:Vector)
		Return New Vector(X - v.X, Y - v.Y)
	End
	
	Method LengthSquared:Float()
		Return ((X * X) + (Y * Y));
	End
	
	Method Length:Float()
		Return Sqrt(LengthSquared());
	End
	
	Method Scale:Vector(Scalar:Float)
		Return New Vector(X * Scalar , Y * Scalar)
	End
	
	Method ScaleLocal:Void(Scalar:Float)
		X *= Scalar
		Y *= Scalar
	End	
	
End