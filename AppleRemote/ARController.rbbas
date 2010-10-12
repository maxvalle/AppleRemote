	#tag Class
	Protected Class ARController
		#tag Method, Flags = &h0
			Sub Constructor()
			  
			  #if targetMacOS
			    
			    myInstances.append new WeakRef(self)
			    setCookieMappingInDictionary
			    
			  #endif
			End Sub
		#tag EndMethod

		#tag Method, Flags = &h21
			Private Function createInterfaceForDevice(hidDevice as UInt32) As memoryBlock
			  
			  #if targetMacOS
			    
			    dim className as new memoryBlock(128)
			    dim pluginInterface as new memoryBlock(4)
			    dim plugInResult as Int32 = 0
			    dim score as Int32 = 0
			    dim ioReturnValue as integer = kIOReturnSuccess
			    
			    // FA12FA38-6F1A-11D4-BA0C-0005028F18D5
			    dim kIOHIDDeviceUserClientTypeID as integer = CFUUIDGetConstantUUIDWithBytes(0, _
			    &hFA, &h12, &hFA, &h38, &h6F, &h1A, &h11, &hD4, _
			    &hBA, &h0C, &h00, &h05, &h02, &h8F, &h18, &hD5)
			    
			    // C244E858-109C-11D4-91D4-0050E4C6426F
			    dim kIOCFPlugInInterfaceID as integer = CFUUIDGetConstantUUIDWithBytes(0, _
			    &hC2, &h44, &hE8, &h58, &h10, &h9C, &h11, &hD4, _
			    &h91, &hD4, &h00, &h50, &hE4, &hC6, &h42, &h6F)
			    
			    // 78BD420C-6F14-11D4-9474-0005028F18D5
			    dim kIOHIDDeviceInterfaceID as integer = CFUUIDGetConstantUUIDWithBytes(0, _
			    &h78, &hBD, &h42, &h0C, &h6F, &h14, &h11, &hD4, _
			    &h94, &h74, &h00, &h05, &h02, &h8F, &h18, &hD5)
			    
			    
			    ioReturnValue = IOObjectGetClass(hidDevice, className)
			    
			    if ioReturnValue <> kIOReturnSuccess then
			      system.debugLog "RBAppleRemote error: Failed to get class name."
			      return nil
			    end if
			    
			    ioReturnValue = IOCreatePlugInInterfaceForService( _
			    hidDevice, _
			    kIOHIDDeviceUserClientTypeID, _
			    kIOCFPlugInInterfaceID, _
			    pluginInterface, _
			    score)
			    
			    if ioReturnValue = kIOReturnSuccess then
			      hidDeviceInterface = newMemoryBlock(4)
			      //Call a method of the intermediate plug-in to create the device interface
			      dim QueryInterfaceMethod as new QueryInterfaceDelegate(pluginInterface.ptr(0).ptr(0).ptr(4))
			      pluginResult = QueryInterfaceMethod.invoke(pluginInterface.ptr(0), CFUUIDGetUUIDBytes(kIOHIDDeviceInterfaceID), hidDeviceInterface)
			      if pluginResult <> 0 then
			        system.debugLog "RBAppleRemote error: Couldn't create HID class device interface."
			      end if
			      
			      if pluginInterface.long(0) <> 0 then
			        dim ReleaseMethod as new ReleaseDelegate(pluginInterface.ptr(0).ptr(0).ptr(12))
			        dim err as integer = ReleaseMethod.invoke(pluginInterface.ptr(0))
			      end if
			    end if
			    
			    return hidDeviceInterface
			    
			  #endif
			End Function
		#tag EndMethod

		#tag Method, Flags = &h0
			Sub Destructor()
			  
			  #if targetMacOS
			    
			    for each ref as WeakRef in myInstances
			      if ref.value = self then
			        myInstances.remove(myInstances.indexOf(ref))
			      end if
			    next
			    
			    if myInstances.ubound = -1 then
			      stopListening
			    end if
			    
			  #endif
			End Sub
		#tag EndMethod

		#tag Method, Flags = &h21
			Private Shared Function findRemoteDevice() As UInt32
			  
			  #if targetMacOS
			    
			    dim hidDevice as UInt32
			    dim hidObjectIterator as UInt32
			    dim hidMatchDictionaryRef as integer
			    dim ioReturnValue as integer = kIOReturnSuccess
			    
			    const kIOMasterPortDefault = 0
			    
			    // Set up a matching dictionary to search the I/O Registry by class
			    // name for all HID class devices
			    hidMatchDictionaryRef = IOServiceMatching("AppleIRController")
			    
			    // Now search I/O Registry for matching devices.
			    ioReturnValue = IOServiceGetMatchingServices(kIOMasterPortDefault, hidMatchDictionaryRef, hidObjectIterator)
			    
			    if ioReturnValue = kIOReturnSuccess and hidObjectIterator <> 0 then
			      hidDevice = IOIteratorNext(hidObjectIterator)
			    end if
			    
			    //Release iterator. Don't need to release iterator objects.
			    call IOObjectRelease(hidObjectIterator)
			    
			    return hidDevice
			    
			  #endif
			End Function
		#tag EndMethod

		#tag Method, Flags = &h21
			Private Sub handleEventWithCookieString(receivedCookieString as string, sumOfValues as integer)
			  
			  #if targetMacOS
			    
			    dim cookieString as string = receivedCookieString
			    
			    if cookieString = "" then
			      return
			    end if
			    
			    if cookieToButtonMapping.hasKey(cookieString) then
			      
			      sendRemoteButtonEvent cookieToButtonMapping.value(cookieString).IntegerValue, (sumOfValues>0)
			      
			    else
			      // let's see if a number of events are stored in the cookie string. this does
			      // happen when the main thread is too busy to handle all incoming events in time.
			      dim subCookieString as string
			      dim lastSubCookieString as string
			      subCookieString = validCookieSubstring(cookieString)
			      while subCookieString <> ""
			        cookieString = mid(cookieString, subCookieString.lenb+1)
			        lastSubCookieString = subCookieString
			        if processBacklog then
			          handleEventWithCookieString subCookieString, sumOfValues
			        end if
			        subCookieString = validCookieSubstring(cookieString)
			      wend
			      if not processBacklog and lastSubCookieString <> "" then
			        // process the last event of the backlog and assume that the button is not pressed down any longer.
			        // The events in the backlog do not seem to be in order and therefore (in rare cases) the last event might be
			        // a button pressed down event while in reality the user has released it.
			        handleEventWithCookieString lastSubCookieString, 0
			      end if
			      if cookieString.lenb > 0 then
			        system.debugLog  "RBAppleRemote: Unknown button for cookiestring "+cookieString
			      end if
			    end if
			    
			  #endif
			  
			exception exc
			End Sub
		#tag EndMethod

		#tag Method, Flags = &h21
			Private Function initializeCookies() As boolean
			  
			  #if targetMacOS
			    
			    dim obj as integer
			    dim number as integer
			    dim cookie as integer
			    dim usage as integer
			    dim usagePage as integer
			    dim elements as integer
			    dim element as integer
			    dim success as integer
			    
			    const kIOHIDElementCookieKey = "ElementCookie"
			    const kCFNumberLongType = 10
			    const kIOHIDElementUsageKey = "Usage"
			    const kIOHIDElementUsagePageKey = "UsagePage"
			    
			    if hidDeviceInterface = nil or hidDeviceInterface.long(0) = 0 then
			      return false
			    end if
			    
			    // Copy all elements, since we're grabbing most of the elements
			    // for this device anyway, and thus, it's faster to iterate them
			    // ourselves. When grabbing only one or two elements, a matching
			    // dictionary should be passed in here instead of NULL.
			    dim copyMatchingElementsMethod as new copyMatchingElementsDelegate(hidDeviceInterface.ptr(0).ptr(0).ptr(80))
			    success = copyMatchingElementsMethod.invoke(hidDeviceInterface.ptr(0), 0, elements)
			    
			    if success = kIOReturnSuccess then
			      dim n as integer = CFArrayGetCount(elements)-1
			      for i as integer = 0 to n
			        element = CFArrayGetValueAtIndex(elements, i)
			        
			        // Get cookie
			        obj = CFDictionaryGetValue(element, CFSTR(kIOHIDElementCookieKey))
			        if obj <> 0 and CFGetTypeID(obj) = CFNumberGetTypeID() then
			          if CFNumberGetValue(obj, kCFNumberLongType, number) then
			            cookie = number
			            
			            //Get usage
			            obj = CFDictionaryGetValue(element, CFSTR(kIOHIDElementUsageKey))
			            if obj <> 0 and CFGetTypeID(obj) = CFNumberGetTypeID() then
			              if CFNumberGetValue(obj, kCFNumberLongType, number) then
			                usage = number
			                
			                //Get usage page
			                obj = CFDictionaryGetValue(element, CFSTR(kIOHIDElementUsagePageKey))
			                if obj <> 0 and CFGetTypeID(obj) = CFNumberGetTypeID() then
			                  if CFNumberGetValue(obj, kCFNumberLongType, number) then
			                    usagePage = number
			                    
			                    cookies.append cookie
			                    
			                  end if
			                end if
			              end if
			            end if
			          end if
			        end if
			      next
			    else
			      return false
			    end if
			    
			    return true
			    
			  #endif
			End Function
		#tag EndMethod

		#tag Method, Flags = &h0
			Function isListeningToRemote() As boolean
			  
			  #if targetMacOS
			    
			    return (hidDeviceInterface <> nil and cookies.ubound > -1 and queue <> nil)
			    
			  #endif
			End Function
		#tag EndMethod

		#tag Method, Flags = &h0
			 Shared Function isRemoteAvailable() As boolean
			  
			  #if targetMacOS
			    
			    dim myHIDDevice as UInt32 = findRemoteDevice()
			    
			    if myHIDDevice <> 0 then
			      call IOObjectRelease(myHIDDevice)
			      return true
			    else
			      return false
			    end if
			    
			  #endif
			End Function
		#tag EndMethod

		#tag Method, Flags = &h21
			Private Function openDevice() As boolean
			  
			  #if targetMacOS
			    
			    dim result as integer
			    dim ioReturnValue as integer
			    dim hasElement as memoryBlock
			    dim index as integer
			    dim theEvent as IOHIDEventStruct
			    
			    dim openMode as UInt32
			    
			    const KERN_SUCCESS = 0
			    const kIOHIDOptionsTypeNone = 0
			    const kIOHIDOptionsTypeSeizeDevice = 1
			    const kIOReturnExclusiveAccess = &hE00002C5
			    
			    if openInExclusiveMode then
			      openMode = kIOHIDOptionsTypeSeizeDevice
			    else
			      openMode = kIOHIDOptionsTypeNone
			    end if
			    
			    // open the device
			    dim openMethod as new openDelegate(hidDeviceInterface.ptr(0).ptr(0).ptr(32))
			    ioReturnValue = openMethod.invoke(hidDeviceInterface.ptr(0), openMode)
			    
			    if ioReturnValue = KERN_SUCCESS then
			      dim allocQueueMethod as new allocQueueDelegate(hidDeviceInterface.ptr(0).ptr(0).ptr(64))
			      queue = allocQueueMethod.invoke(hidDeviceInterface.ptr(0))
			      
			      if queue <> nil then
			        
			        dim createMethod as new createDelegate(queue.ptr(0).ptr(32))
			        result = createMethod.invoke(queue, 0, 12) // depth: maximum number of elements in queue before oldest elements in queue begin to be lost.
			        
			        // add elements to the queue
			        dim addElementMethod as new addElementDelegate(queue.ptr(0).ptr(40))
			        for each cookie as integer in cookies
			          call addElementMethod.invoke(queue, cookie, 0)
			        next
			        
			        // add callback for async events
			        dim createAsyncEventSourceMethod as new createAsyncEventSourceDelegate(queue.ptr(0).ptr(16))
			        ioReturnValue = createAsyncEventSourceMethod.invoke(queue, eventSource)
			        if ioReturnValue = KERN_SUCCESS then
			          dim setEventCalloutMethod as new setEventCalloutDelegate(queue.ptr(0).ptr(64))
			          ioReturnValue = setEventCalloutMethod.invoke(queue, addressOf queueCallback, 0, 0)
			          if ioReturnValue = KERN_SUCCESS then
			            CFRunLoopAddSource(CFRunLoopGetCurrent(), eventSource, CFSTR(kCFRunLoopDefaultMode))
			            
			            // start data delivery to queue
			            dim startMethod as new startDelegate(queue.ptr(0).ptr(52))
			            call startMethod.invoke(queue)
			            return true
			          else
			            system.debugLog "RBAppleRemote error: Error when setting event callback"
			          end if
			        else
			          system.debugLog "RBAppleRemote error: Error when creating async event source"
			        end if
			        
			      else
			        system.debugLog "RBAppleRemote error: Error when opening device"
			      end if
			      
			    elseif ioReturnValue = kIOReturnExclusiveAccess then
			      
			    end if
			    
			    return false
			    
			  #endif
			End Function
		#tag EndMethod

		#tag Method, Flags = &h21
			Private Shared Sub queueCallback(target as integer, result as integer, refcon as integer, sender as integer)
			  
			  #if targetMacOS
			    
			    dim theEvent as IOHIDEventStruct
			    dim zeroTime as UnsignedWide
			    dim cookieString as string
			    dim sumOfValues as integer
			    
			    while result = kIOReturnSuccess
			      dim getNextEventMethod as new getNextEventDelegate(queue.ptr(0).ptr(60))
			      result = getNextEventMethod.invoke(queue, theEvent, zeroTime, 0)
			      if result = kIOReturnSuccess then
			        if theEvent.elementCookie <> 5 then
			          sumOfValues = sumOfValues+theEvent.value
			          cookieString = cookieString+str(theEvent.elementCookie)+"_"
			        end if
			      end if
			    wend
			    
			    for each instanceRef as WeakRef in myInstances
			      ARController(instanceRef.value).handleEventWithCookieString cookieString, sumOfValues
			    next
			    
			  #endif
			  
			exception exc
			  
			End Sub
		#tag EndMethod

		#tag Method, Flags = &h21
			Private Sub sendRemoteButtonEvent(buttonID as integer, pressedDown as boolean)
			  
			  #if targetMacOS
			    
			    'if not pressedDown and buttonID = kRemoteButtonMenu_Hold then
			    '// There is no separate event for pressed down on menu hold. We are simulating that event here
			    'sendRemoteButtonEvent ButtonID, true
			    'end if
			    '
			    'raiseEvent ButtonPressed integer(ButtonID), pressedDown
			    '
			    'if pressedDown and _
			    '(ButtonID = kRemoteButtonRight or _
			    'ButtonID = kRemoteButtonLeft or _
			    'ButtonID = kRemoteButtonPlay or _
			    'ButtonID = kRemoteButtonMenu or _
			    'ButtonID = kRemoteButtonPlay_Hold) then
			    '// There is no separate event when the button is being released. We are simulating that event here
			    'sendRemoteButtonEvent ButtonID, false
			    'end if
			    
			    select case buttonID
			    case kRemoteButtonMenu_Hold
			      raiseEvent MenuHold
			      
			    case kRemoteButtonMenu
			      raiseEvent MenuPress
			      
			    case kRemoteButtonPlay_Hold
			      raiseEvent PlayHold
			      
			    case kRemoteButtonPlay, kRemoteButtonPlay_Alu
			      raiseEvent PlayPress
			      
			    case kRemoteButtonLeft_Hold
			      if pressedDown then
			        raiseEvent TrackLeftHoldDown
			      else
			        raiseEvent TrackLeftHoldUp
			      end if
			      
			    case kRemoteButtonLeft
			      raiseEvent TrackLeftPress
			      
			    case kRemoteButtonRight_Hold
			      if pressedDown then
			        raiseEvent TrackRightHoldDown
			      else
			        raiseEvent TrackRightHoldUp
			      end if
			      
			    case kRemoteButtonRight
			      raiseEvent TrackRightPress
			      
			    case kRemoteButtonMinus
			      if pressedDown then
			        raiseEvent VolumeMinusKeyDown
			      else
			        raiseEvent VolumeMinusKeyUp
			      end if
			      
			    case kRemoteButtonPlus
			      if pressedDown then
			        raiseEvent VolumePlusKeyDown
			      else
			        raiseEvent VolumePlusKeyUp
			      end if
			      
			    case kRemoteButtonCentral
			      raiseEvent CentralPress
			      
			    case kRemoteButtonCentral_Hold
			      raiseEvent CentralHold
			      
			      'case kRemoteControl_Switched
			      'raiseEvent RemoteControlSwitched
			      
			    end select
			    
			  #endif
			End Sub
		#tag EndMethod

		#tag Method, Flags = &h21
			Private Shared Sub setCookieMappingInDictionary()
			  
			  #if targetMacOS
			    
			    if cookieToButtonMapping = nil then
			      cookieToButtonMapping = new dictionary
			      if isTiger then
			        cookieToButtonMapping.value("14_12_11_6_") = kRemoteButtonPlus
			        cookieToButtonMapping.value("14_13_11_6_") = kRemoteButtonMinus
			        cookieToButtonMapping.value("14_7_6_14_7_6_") = kRemoteButtonMenu
			        cookieToButtonMapping.value("14_8_6_14_8_6_") = kRemoteButtonPlay
			        cookieToButtonMapping.value("14_9_6_14_9_6_") = kRemoteButtonRight
			        cookieToButtonMapping.value("14_10_6_14_10_6_") = kRemoteButtonLeft
			        cookieToButtonMapping.value("14_6_4_2_") = kRemoteButtonRight_Hold
			        cookieToButtonMapping.value("14_6_3_2_") = kRemoteButtonLeft_Hold
			        cookieToButtonMapping.value("14_6_14_6_") = kRemoteButtonMenu_Hold
			        cookieToButtonMapping.value("18_14_6_18_14_6_") = kRemoteButtonPlay_Hold
			        cookieToButtonMapping.value("19_") = kRemoteControl_Switched
			      elseif isLeopard then
			        cookieToButtonMapping.value("31_29_28_19_18_") = kRemoteButtonPlus
			        cookieToButtonMapping.value("31_30_28_19_18_") = kRemoteButtonMinus
			        cookieToButtonMapping.value("31_20_19_18_31_20_19_18_") = kRemoteButtonMenu
			        cookieToButtonMapping.value("31_21_19_18_31_21_19_18_") = kRemoteButtonPlay
			        cookieToButtonMapping.value("31_22_19_18_31_22_19_18_") = kRemoteButtonRight
			        cookieToButtonMapping.value("31_23_19_18_31_23_19_18_") = kRemoteButtonLeft
			        cookieToButtonMapping.value("31_19_18_4_2_") = kRemoteButtonRight_Hold
			        cookieToButtonMapping.value("31_19_18_3_2_") = kRemoteButtonLeft_Hold
			        cookieToButtonMapping.value("31_19_18_31_19_18_") = kRemoteButtonMenu_Hold
			        cookieToButtonMapping.value("35_31_19_18_35_31_19_18_") = kRemoteButtonPlay_Hold
			        cookieToButtonMapping.value("19_") = kRemoteControl_Switched
			      elseif isSnowLeopard then
			        cookieToButtonMapping.value("33_31_30_21_20_2_") = kRemoteButtonPlus
			        cookieToButtonMapping.value("33_32_30_21_20_2_") = kRemoteButtonMinus
			        cookieToButtonMapping.value("33_22_21_20_2_33_22_21_20_2_") = kRemoteButtonMenu
			        cookieToButtonMapping.value("33_23_21_20_2_33_23_21_20_2_") = kRemoteButtonPlay
			        cookieToButtonMapping.value("33_24_21_20_2_33_24_21_20_2_") = kRemoteButtonRight
			        cookieToButtonMapping.value("33_25_21_20_2_33_25_21_20_2_") = kRemoteButtonLeft
			        cookieToButtonMapping.value("33_21_20_14_12_2_") = kRemoteButtonRight_Hold
			        cookieToButtonMapping.value("33_21_20_13_12_2_") = kRemoteButtonLeft_Hold
			        cookieToButtonMapping.value("33_21_20_2_33_21_20_2_") = kRemoteButtonMenu_Hold
			        cookieToButtonMapping.value("37_33_21_20_2_37_33_21_20_2_") = kRemoteButtonPlay_Hold
			        cookieToButtonMapping.value("33_21_20_8_2_33_21_20_8_2_") = kRemoteButtonPlay_Alu
			        cookieToButtonMapping.value("33_21_20_3_2_33_21_20_3_2_") = kRemoteButtonCentral
			        cookieToButtonMapping.value("33_21_20_11_2_33_21_20_11_2_") = kRemoteButtonCentral_Hold
			        cookieToButtonMapping.value("19_") = kRemoteControl_Switched
			      end if
			    end if
			    
			  #endif
			  
			End Sub
		#tag EndMethod

		#tag Method, Flags = &h0
			Sub startListening()
			  
			  #if targetMacOS
			    
			    if isListeningToRemote then
			      return
			    end if
			    
			    dim hidDevice as UInt32 = findRemoteDevice()
			    if hidDevice = 0 then
			      return
			    end if
			    
			    if openInExclusiveMode then
			      call EnableSecureEventInput()
			    end if
			    
			    if createInterfaceForDevice(hidDevice) = nil then
			      stopListening
			    end if
			    
			    if not initializeCookies then
			      stopListening
			    end if
			    
			    if not openDevice then
			      stopListening
			    end if
			    
			    call IOObjectRelease(hidDevice)
			    
			    return
			    
			  #endif
			End Sub
		#tag EndMethod

		#tag Method, Flags = &h0
			Sub stopListening()
			  
			  #if targetMacOS
			    
			    if not isListeningToRemote then
			      return
			    end if
			    
			    if eventSource <> 0 then
			      CFRunLoopRemoveSource CFRunLoopGetCurrent(), eventSource, CFSTR(kCFRunLoopDefaultMode)
			      CFRelease eventSource
			      eventSource = 0
			    end if
			    
			    if queue <> nil and queue.long(0) <> 0 then
			      // stop data delivery to queue
			      dim stopMethod as new stopDelegate(queue.ptr(0).ptr(56))
			      call stopMethod.invoke(queue)
			      
			      // dispose of queue
			      dim disposeMethod as new disposeDelegate(queue.ptr(0).ptr(36))
			      call disposeMethod.invoke(queue)
			      
			      // release the queue we allocated
			      dim releaseMethod as new releaseDelegate(queue.ptr(0).ptr(12))
			      call releaseMethod.invoke(queue)
			      
			      queue = nil
			    end if
			    
			    if cookies.ubound > -1 then
			      redim cookies(-1)
			    end if
			    
			    if hidDeviceInterface <> nil and hidDeviceInterface.long(0) <> 0 then
			      // close the device
			      dim closeMethod as new closeDelegate(hidDeviceInterface.ptr(0).ptr(0).ptr(36))
			      call closeMethod.invoke(hidDeviceInterface.ptr(0))
			      
			      //release the interface
			      dim ReleaseMethod as new ReleaseDelegate(hidDeviceInterface.ptr(0).ptr(0).ptr(12))
			      call ReleaseMethod.invoke(hidDeviceInterface.ptr(0))
			      
			      hidDeviceInterface = nil
			    end if
			    
			    if openInExclusiveMode then
			      call DisableSecureEventInput()
			    end if
			    
			  #endif
			End Sub
		#tag EndMethod

		#tag Method, Flags = &h21
			Private Function validCookieSubstring(cookieString as string) As string
			  
			  #if targetMacOS
			    
			    if cookieString = "" then
			      return ""
			    end if
			    
			    dim n as integer = cookieToButtonMapping.count-1
			    for i as integer = 0 to n
			      dim key as string = cookieToButtonMapping.key(i).stringValue
			      if instr(cookieString, key) = 1 then
			        return key
			      end if
			    next
			    
			    return ""
			    
			  #endif
			End Function
		#tag EndMethod


		#tag Hook, Flags = &h0
			Event CentralHold()
		#tag EndHook

		#tag Hook, Flags = &h0
			Event CentralPress()
		#tag EndHook

		#tag Hook, Flags = &h0
			Event MenuHold()
		#tag EndHook

		#tag Hook, Flags = &h0
			Event MenuPress()
		#tag EndHook

		#tag Hook, Flags = &h0
			Event PlayHold()
		#tag EndHook

		#tag Hook, Flags = &h0
			Event PlayPress()
		#tag EndHook

		#tag Hook, Flags = &h0
			Event TrackLeftHoldDown()
		#tag EndHook

		#tag Hook, Flags = &h0
			Event TrackLeftHoldUp()
		#tag EndHook

		#tag Hook, Flags = &h0
			Event TrackLeftPress()
		#tag EndHook

		#tag Hook, Flags = &h0
			Event TrackRightHoldDown()
		#tag EndHook

		#tag Hook, Flags = &h0
			Event TrackRightHoldUp()
		#tag EndHook

		#tag Hook, Flags = &h0
			Event TrackRightPress()
		#tag EndHook

		#tag Hook, Flags = &h0
			Event VolumeMinusKeyDown()
		#tag EndHook

		#tag Hook, Flags = &h0
			Event VolumeMinusKeyUp()
		#tag EndHook

		#tag Hook, Flags = &h0
			Event VolumePlusKeyDown()
		#tag EndHook

		#tag Hook, Flags = &h0
			Event VolumePlusKeyUp()
		#tag EndHook


		#tag Property, Flags = &h21
			Private Shared cookies() As Integer
		#tag EndProperty

		#tag Property, Flags = &h21
			Private Shared cookieToButtonMapping As dictionary
		#tag EndProperty

		#tag Property, Flags = &h21
			Private Shared eventSource As Integer
		#tag EndProperty

		#tag ComputedProperty, Flags = &h0
			#tag Getter
				Get
				  
				  return openInExclusiveMode
				  
				End Get
			#tag EndGetter
			#tag Setter
				Set
				  
				  if not self.isListeningToRemote then
				    openInExclusiveMode = value
				  end if
				  
				End Set
			#tag EndSetter
			ExclusiveMode As boolean
		#tag EndComputedProperty

		#tag Property, Flags = &h21
			Private Shared hidDeviceInterface As memoryBlock
		#tag EndProperty

		#tag Property, Flags = &h21
			Private Shared myInstances() As WeakRef
		#tag EndProperty

		#tag Property, Flags = &h21
			Private Shared openInExclusiveMode As boolean
		#tag EndProperty

		#tag Property, Flags = &h0
			processBacklog As boolean
		#tag EndProperty

		#tag Property, Flags = &h21
			Private Shared queue As memoryBlock
		#tag EndProperty


		#tag Constant, Name = kCFRunLoopDefaultMode, Type = String, Dynamic = False, Default = \"kCFRunLoopDefaultMode", Scope = Private
		#tag EndConstant

		#tag Constant, Name = kIOReturnSuccess, Type = Double, Dynamic = False, Default = \"0", Scope = Private
		#tag EndConstant

		#tag Constant, Name = kRemoteButtonCentral, Type = Double, Dynamic = False, Default = \"12", Scope = Public
		#tag EndConstant

		#tag Constant, Name = kRemoteButtonCentral_Hold, Type = Double, Dynamic = False, Default = \"13", Scope = Public
		#tag EndConstant

		#tag Constant, Name = kRemoteButtonLeft, Type = Double, Dynamic = False, Default = \"5", Scope = Public
		#tag EndConstant

		#tag Constant, Name = kRemoteButtonLeft_Hold, Type = Double, Dynamic = False, Default = \"11", Scope = Public
		#tag EndConstant

		#tag Constant, Name = kRemoteButtonMenu, Type = Double, Dynamic = False, Default = \"2", Scope = Public
		#tag EndConstant

		#tag Constant, Name = kRemoteButtonMenu_Hold, Type = Double, Dynamic = False, Default = \"8", Scope = Public
		#tag EndConstant

		#tag Constant, Name = kRemoteButtonMinus, Type = Double, Dynamic = False, Default = \"1", Scope = Public
		#tag EndConstant

		#tag Constant, Name = kRemoteButtonMinus_Hold, Type = Double, Dynamic = False, Default = \"7", Scope = Public
		#tag EndConstant

		#tag Constant, Name = kRemoteButtonPlay, Type = Double, Dynamic = False, Default = \"3", Scope = Public
		#tag EndConstant

		#tag Constant, Name = kRemoteButtonPlay_Alu, Type = Double, Dynamic = False, Default = \"14", Scope = Public
		#tag EndConstant

		#tag Constant, Name = kRemoteButtonPlay_Hold, Type = Double, Dynamic = False, Default = \"9", Scope = Public
		#tag EndConstant

		#tag Constant, Name = kRemoteButtonPlus, Type = Double, Dynamic = False, Default = \"0", Scope = Public
		#tag EndConstant

		#tag Constant, Name = kRemoteButtonPlus_Hold, Type = Double, Dynamic = False, Default = \"6", Scope = Public
		#tag EndConstant

		#tag Constant, Name = kRemoteButtonRight, Type = Double, Dynamic = False, Default = \"4", Scope = Public
		#tag EndConstant

		#tag Constant, Name = kRemoteButtonRight_Hold, Type = Double, Dynamic = False, Default = \"10", Scope = Public
		#tag EndConstant

		#tag Constant, Name = kRemoteControl_Switched, Type = Double, Dynamic = False, Default = \"15", Scope = Public
		#tag EndConstant


		#tag ViewBehavior
			#tag ViewProperty
				Name="ExclusiveMode"
				Visible=true
				Group="Behavior"
				InitialValue="false"
				Type="boolean"
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
