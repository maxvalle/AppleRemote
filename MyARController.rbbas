#tag Class
Protected Class MyARController
Inherits AppleRemote.ARController
	#tag Event
		Sub CentralHold()
		  Window1.hold = true
		  Window1.ButtonCanvas(9).visible = true
		  Window1.Timer1.period = 180
		  Window1.Timer1.mode = 1
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub CentralPress()
		  Window1.hold = false
		  Window1.ButtonCanvas(9).visible = true
		  Window1.Timer1.period = 90
		  Window1.Timer1.mode = 1
		End Sub
	#tag EndEvent

	#tag Event
		Sub MenuHold()
		  Window1.hold = true
		  Window1.ButtonCanvas(2).visible = true
		  Window1.ButtonCanvas(8).visible = true
		  Window1.Timer1.period = 180
		  Window1.Timer1.mode = 1
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub MenuPress()
		  Window1.hold = false
		  Window1.ButtonCanvas(2).visible = true
		  Window1.ButtonCanvas(8).visible = true
		  Window1.Timer1.period = 90
		  Window1.Timer1.mode = 1
		End Sub
	#tag EndEvent

	#tag Event
		Sub PlayHold()
		  Window1.hold = true
		  Window1.ButtonCanvas(3).visible = true
		  Window1.ButtonCanvas(12).visible = true
		  Window1.Timer1.period = 180
		  Window1.Timer1.mode = 1
		End Sub
	#tag EndEvent

	#tag Event
		Sub PlayPress()
		  Window1.hold = false
		  Window1.ButtonCanvas(3).visible = true
		  Window1.ButtonCanvas(12).visible = true
		  Window1.Timer1.period = 90
		  Window1.Timer1.mode = 1
		End Sub
	#tag EndEvent

	#tag Event
		Sub RemoteControlSwitched()
		  Window1.SwitchedLabel.visible = true
		  Window1.Timer1.period = 90
		  Window1.Timer1.mode = 1
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub TrackLeftHoldDown()
		  Window1.hold = true
		  Window1.ButtonCanvas(4).visible = true
		  Window1.ButtonCanvas(10).visible = true
		End Sub
	#tag EndEvent

	#tag Event
		Sub TrackLeftHoldUp()
		  Window1.hold = false
		  Window1.ButtonCanvas(4).visible = false
		  Window1.ButtonCanvas(10).visible = false
		End Sub
	#tag EndEvent

	#tag Event
		Sub TrackLeftPress()
		  Window1.hold = false
		  Window1.ButtonCanvas(4).visible = true
		  Window1.ButtonCanvas(10).visible = true
		  Window1.Timer1.period = 90
		  Window1.Timer1.mode = 1
		End Sub
	#tag EndEvent

	#tag Event
		Sub TrackRightHoldDown()
		  Window1.hold = true
		  Window1.ButtonCanvas(5).visible = true
		  Window1.ButtonCanvas(11).visible = true
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub TrackRightHoldUp()
		  Window1.hold = false
		  Window1.ButtonCanvas(5).visible = false
		  Window1.ButtonCanvas(11).visible = false
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub TrackRightPress()
		  Window1.hold = false
		  Window1.ButtonCanvas(5).visible = true
		  Window1.ButtonCanvas(11).visible = true
		  Window1.Timer1.period = 90
		  Window1.Timer1.mode = 1
		End Sub
	#tag EndEvent

	#tag Event
		Sub VolumeMinusKeyDown()
		  Window1.hold = true
		  Window1.ButtonCanvas(1).visible = true
		  Window1.ButtonCanvas(7).visible = true
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub VolumeMinusKeyUp()
		  Window1.hold = false
		  Window1.ButtonCanvas(1).visible = false
		  Window1.ButtonCanvas(7).visible = false
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub VolumePlusKeyDown()
		  Window1.hold = true
		  Window1.ButtonCanvas(0).visible = true
		  Window1.ButtonCanvas(6).visible = true
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub VolumePlusKeyUp()
		  Window1.hold = false
		  Window1.ButtonCanvas(0).visible = false
		  Window1.ButtonCanvas(6).visible = false
		  
		End Sub
	#tag EndEvent


	#tag ViewBehavior
		#tag ViewProperty
			Name="ExclusiveMode"
			Visible=true
			Group="Behavior"
			InitialValue="false"
			Type="boolean"
			InheritedFrom="AppleRemote.ARController"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="processBacklog"
			Visible=true
			Group="Behavior"
			InitialValue="false"
			Type="boolean"
			InheritedFrom="AppleRemote.ARController"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
