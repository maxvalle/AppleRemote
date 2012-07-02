#tag Module
Protected Module AppleRemote
	#tag DelegateDeclaration, Flags = &h21
		Private Delegate Function addElementDelegate(selfp as ptr, elementCookie as integer, flags as UInt32) As integer
	#tag EndDelegateDeclaration

	#tag DelegateDeclaration, Flags = &h21
		Private Delegate Function allocQueueDelegate(selfp as ptr) As ptr
	#tag EndDelegateDeclaration

	#tag ExternalMethod, Flags = &h21
		Private Soft Declare Function CFArrayGetCount Lib "CoreFoundation" (theArray as integer) As integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h21
		Private Soft Declare Function CFArrayGetValueAtIndex Lib "CoreFoundation" (theArray as integer, idx as integer) As integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h21
		Private Soft Declare Function CFDictionaryGetValue Lib "CoreFoundation" (theDict as integer, key as ptr) As integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h21
		Private Soft Declare Function CFGetTypeID Lib "CoreFoundation" (cf as integer) As UInt32
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h21
		Private Soft Declare Function CFNumberGetTypeID Lib "CoreFoundation" () As UInt32
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h21
		Private Soft Declare Function CFNumberGetValue Lib "CoreFoundation" (number as integer, theType as integer, byRef valuePtr as integer) As boolean
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h21
		Private Soft Declare Sub CFRelease Lib "CoreFoundation" (cf as integer)
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h21
		Private Soft Declare Sub CFRunLoopAddSource Lib "CoreFoundation" (rl as integer, source as integer, mode as Ptr)
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h21
		Private Soft Declare Function CFRunLoopGetCurrent Lib "CoreFoundation" () As integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h21
		Private Soft Declare Sub CFRunLoopRemoveSource Lib "CoreFoundation" (rl as integer, source as integer, mode as Ptr)
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h21
		Private Soft Declare Function CFUUIDGetConstantUUIDWithBytes Lib "CoreFoundation" (alloc as integer, byte0 as UInt8, byte1 as UInt8, byte2 as UInt8, byte3 as UInt8, byte4 as UInt8, byte5 as UInt8, byte6 as UInt8, byte7 as UInt8, byte8 as UInt8, byte9 as UInt8, byte10 as UInt8, byte11 as UInt8, byte12 as UInt8, byte13 as UInt8, byte14 as UInt8, byte15 as UInt8) As integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h21
		Private Soft Declare Function CFUUIDGetUUIDBytes Lib "CoreFoundation" (uuid as integer) As CFUUIDBytes
	#tag EndExternalMethod

	#tag DelegateDeclaration, Flags = &h21
		Private Delegate Function closeDelegate(selfp as ptr) As integer
	#tag EndDelegateDeclaration

	#tag DelegateDeclaration, Flags = &h21
		Private Delegate Function copyMatchingElementsDelegate(selfp as ptr, matchingDict as integer, byRef elements as integer) As integer
	#tag EndDelegateDeclaration

	#tag DelegateDeclaration, Flags = &h21
		Private Delegate Function createAsyncEventSourceDelegate(selfp as ptr, byRef source as integer) As integer
	#tag EndDelegateDeclaration

	#tag DelegateDeclaration, Flags = &h21
		Private Delegate Function createDelegate(selfp as ptr, flags as UInt32, depth as UInt32) As integer
	#tag EndDelegateDeclaration

	#tag ExternalMethod, Flags = &h21
		Private Soft Declare Function DisableSecureEventInput Lib "Carbon" () As integer
	#tag EndExternalMethod

	#tag DelegateDeclaration, Flags = &h21
		Private Delegate Function disposeDelegate(selfp as ptr) As integer
	#tag EndDelegateDeclaration

	#tag ExternalMethod, Flags = &h21
		Private Soft Declare Function EnableSecureEventInput Lib "Carbon" () As integer
	#tag EndExternalMethod

	#tag DelegateDeclaration, Flags = &h21
		Private Delegate Function getNextEventDelegate(selfp as ptr, byRef theEvent as IOHIDEventStruct, maxTime as UnsignedWide, timeoutMS as UInt32) As integer
	#tag EndDelegateDeclaration

	#tag ExternalMethod, Flags = &h21
		Private Soft Declare Function IOCreatePlugInInterfaceForService Lib "IOKit" (service as UInt32, pluginType as integer, interfaceType as integer, theInterface as Ptr, byRef theScore as integer) As integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h21
		Private Soft Declare Function IOIteratorNext Lib "IOKit" (iterator as integer) As integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h21
		Private Soft Declare Function IOObjectGetClass Lib "IOKit" (obj as integer, className as ptr) As integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h21
		Private Soft Declare Function IOObjectRelease Lib "IOKit" (obj as UInt32) As integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h21
		Private Soft Declare Function IOServiceGetMatchingServices Lib "IOKit" (masterPort as UInt32, matching as integer, byRef existing as UInt32) As integer
	#tag EndExternalMethod

	#tag ExternalMethod, Flags = &h21
		Private Soft Declare Function IOServiceMatching Lib "IOKit" (name as cstring) As integer
	#tag EndExternalMethod

	#tag DelegateDeclaration, Flags = &h21
		Private Delegate Function openDelegate(selfp as ptr, flags as UInt32) As integer
	#tag EndDelegateDeclaration

	#tag DelegateDeclaration, Flags = &h21
		Private Delegate Function QueryInterfaceDelegate(thisPointer as Ptr, iid as CFUUIDBytes, ppv as ptr) As integer
	#tag EndDelegateDeclaration

	#tag DelegateDeclaration, Flags = &h21
		Private Delegate Function ReleaseDelegate(thisPointer as Ptr) As UInt32
	#tag EndDelegateDeclaration

	#tag DelegateDeclaration, Flags = &h21
		Private Delegate Function setEventCalloutDelegate(selfp as ptr, callback as ptr, callbackTarget as integer, callbackRefcon as integer) As integer
	#tag EndDelegateDeclaration

	#tag DelegateDeclaration, Flags = &h21
		Private Delegate Function startDelegate(selfp as ptr) As integer
	#tag EndDelegateDeclaration

	#tag DelegateDeclaration, Flags = &h21
		Private Delegate Function stopDelegate(selfp as ptr) As integer
	#tag EndDelegateDeclaration

	#tag Method, Flags = &h21
		Private Function _CFSTR(inStr as string) As Ptr
		  
		  // from MacOSLib
		  // The use of CFRetain here provides a slick way to convert a REALbasic CFStringRef to a Ptr
		  soft declare function CFRetain lib "Carbon" (cf as CFStringRef) as Ptr
		  
		  return CFRetain(inStr)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function _isLeopard() As boolean
		  
		  return (_OSVersion >= &h1050 and _OSVersion < &h1060)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function _isSnowLeopardOrLater() As boolean
		  
		  return (_OSVersion >= &h1060)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function _isTiger() As boolean
		  
		  return (_OSVersion >= &h1040 and _OSVersion < &h1050)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function _OSVersion() As integer
		  
		  #if targetMacOS
		    
		    dim res as Integer
		    
		    call System.Gestalt( "sysv", res )
		    
		    return res
		    
		  #endif
		End Function
	#tag EndMethod


	#tag Note, Name = Info
		
		AppleRemote
		REALbasic class to handle the Apple Remote
		
		Copyright (c)2008-2012, Massimo Valle
		All rights reserved.
		
		This class is based on the Cocoa code of  Martin Kahr <http://martinkahr.com/source-code/> which is also based on what
		discussed here: <http://www.cocoadev.com/index.pl?UsingTheAppleRemoteControl>
		
		Redistribution and use in source and binary forms, with or without modification,
		are permitted provided that the following conditions are met:
		- Redistributions of source code must retain the above copyright notice,
		this list of conditions and the following disclaimer.
		- Redistributions in binary form must reproduce the above copyright notice,
		this list of conditions and the following disclaimer in the documentation and/or
		other materials provided with the distribution.
		- Neither the name of the author nor the names of its contributors may be used to
		endorse or promote products derived from this software without specific prior written permission.
		
		THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
		IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
		FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
		CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
		DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
		DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
		IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
		OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	#tag EndNote


	#tag Structure, Name = CFUUIDBytes, Flags = &h21
		byte0 as UInt8
		  byte1 as UInt8
		  byte2 as UInt8
		  byte3 as UInt8
		  byte4 as UInt8
		  byte5 as UInt8
		  byte6 as UInt8
		  byte7 as UInt8
		  byte8 as UInt8
		  byte9 as UInt8
		  byte10 as UInt8
		  byte11 as UInt8
		  byte12 as UInt8
		  byte13 as UInt8
		  byte14 as UInt8
		byte15 as UInt8
	#tag EndStructure

	#tag Structure, Name = IOHIDEventStruct, Flags = &h21
		type as integer
		  elementCookie as integer
		  value as integer
		  timeStamp as UnsignedWide
		  longValueSize as UInt32
		longValue as integer
	#tag EndStructure

	#tag Structure, Name = UnsignedWide, Flags = &h21
		lo as UInt32
		hi as UInt32
	#tag EndStructure


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
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
End Module
#tag EndModule
