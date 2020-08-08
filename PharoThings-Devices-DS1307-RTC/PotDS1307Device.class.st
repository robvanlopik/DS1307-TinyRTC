"
I represent a battery backup Real Time Clock plus some niceties
I can be set with a DateAndTime valuethat will tick along and can be queried
I (the device) know about month length, leap years. Unfortunately not about summer and winter time.
Accuracy isabout ... per month

My physical place is on the I2C bus of the board that hosts me

Public API and Key Messages

- message one   
- message two 
- (for bonus points) how to create instances.

Bonuses: I have a pin on which I can generate a square wave with frequencies of:..

Furthermore I possess  54 bytes of RAM that is backed up by the battery, addresses with index 1 to 54
 
Internal Representation and Key Implementation Points.


    Implementation Points
"
Class {
	#name : #PotDS1307Device,
	#superclass : #PotI2CDevice,
	#category : #'PharoThings-Devices-DS1307-RTC'
}

{ #category : #'instance creation' }
PotDS1307Device class >> defaultI2CAddress [
	"Note: the TinyRTC device also contains a 24C32 EEPROM at address 16r50). This can betreated as a different device; we will cal it PotDS3107MEEPROM"
	^16r68
]

{ #category : #accessing }
PotDS1307Device >> dateAndTime [
	"retrieve a complete DateAndTime object from the RTC"

	^DateAndTime basicYear: (self year + 2000)
					month: (self month)
					day: (self day)
					hour: (self hour)
					minute: (self minute)
					second: (self second)
					nanoSecond: 0
					offset: DateAndTime localOffset
					
					
]

{ #category : #'private - utilities' }
PotDS1307Device >> dateAndTime: aDateAndTime [
	"set the RTC to the specified date and time"

	self second: aDateAndTime second.
	self minute: aDateAndTime minute.
	self hour: aDateAndTime hour.
	self dayOfWeek: aDateAndTime dayOfWeek.
	self day: aDateAndTime dayOfMonth.
	self month: aDateAndTime month.
	self year: ((aDateAndTime  year) - 2000)
	
	
]

{ #category : #accessing }
PotDS1307Device >> day [
	^self readRegister: 4
]

{ #category : #accessing }
PotDS1307Device >> day: anInt [
	self writeRegister: 4 data: anInt
]

{ #category : #accessing }
PotDS1307Device >> dayOfWeek [ 
	^self readRegister: 3
]

{ #category : #accessing }
PotDS1307Device >> dayOfWeek: anInt [
	self writeRegister: 3 data: anInt
]

{ #category : #output }
PotDS1307Device >> disableSquareWave [
	"disable square wave output"

	i2cConnection write8BitsAt: 16r07 data: 0
]

{ #category : #output }
PotDS1307Device >> enableSquareWave1Hz [
	"output 1 Hz square wave on pin SQW/OUT"

	| temporary variable names |
	
]

{ #category : #output }
PotDS1307Device >> enableSquareWave32kHz [
	"32.768 kHz on pin SQW/OUT"

	i2cConnection write8BitsAt: 16r07 data: 16r13
]

{ #category : #output }
PotDS1307Device >> enableSquareWave4kHz [
	"4.096 kHz on pin SQW/OUT"

	i2cConnection write8BitsAt: 16r07 data: 16r11
]

{ #category : #output }
PotDS1307Device >> enableSquareWave8kHz [
	"8.192 kHz on pin SQW/OUT"

	i2cConnection write8BitsAt: 16r07 data: 16r12
]

{ #category : #accessing }
PotDS1307Device >> hour [
	"we assume 24-hours format"
	^self readRegister: 2
]

{ #category : #accessing }
PotDS1307Device >> hour: anInt [
	self writeRegister: 2 data: anInt
]

{ #category : #'private - utilities' }
PotDS1307Device >> intFromBCD: aBCDByte [
	"return the int value of a packedBCD byte"

	^10 * (aBCDByte bitShift: -4) + (aBCDByte bitAnd: 16r0F)
]

{ #category : #output }
PotDS1307Device >> isRunning [
	"check the MSB of register 0. If it is 1, the clock is not running and the date is invalid"

	| answer |
	answer := self readRegister: 0.
	^((answer bitAnd: 2r10000000) = 0 ) 
]

{ #category : #accessing }
PotDS1307Device >> memoryAt: anIndex [
	"comment stating purpose of message"

	^i2cConnection read8BitsAt: (anIndex + 7)
	
]

{ #category : #accessing }
PotDS1307Device >> memoryAt: anIndex put: aByte [
	"write aByte to RAM. we must check the index, because we don't want to risk overwriting the clock"

	((anIndex < 1) or: (anIndex > 56)) ifTrue: [ ^self error: 'index out of bounds' ].
	
	i2cConnection write8BitsAt: (anIndex + 7) data: aByte.
	
]

{ #category : #accessing }
PotDS1307Device >> minute [
	^self readRegister: 1
]

{ #category : #accessing }
PotDS1307Device >> minute: anInt [
	self writeRegister: 1 data: anInt
]

{ #category : #accessing }
PotDS1307Device >> month [ 
	^self readRegister: 5
]

{ #category : #accessing }
PotDS1307Device >> month: anInt [
	self writeRegister: 5 data: anInt
]

{ #category : #'private - utilities' }
PotDS1307Device >> packedBCDFromInt: anInt [
	"convert a number (0..99) to packed BCD"

	^(anInt // 10) * 16 + (anInt \\ 10)
]

{ #category : #accessing }
PotDS1307Device >> readRegister: anInteger [
	"read register anInterger and convert from BCD"

	^self intFromBCD: (i2cConnection read8BitsAt: anInteger)

]

{ #category : #accessing }
PotDS1307Device >> second [
	"read the secondsregister"
	| sec |
	sec := self readRegister: 0.
	(sec > 60) ifTrue: [^ self error: 'clock not running' ].
	^sec
]

{ #category : #accessing }
PotDS1307Device >> second: anInt [
	
	self writeRegister: 0 data: anInt
]

{ #category : #accessing }
PotDS1307Device >> writeRegister: anInteger data: aNumber [
	"comment stating purpose of message"

	i2cConnection write8BitsAt: anInteger data: (self packedBCDFromInt: aNumber)
]

{ #category : #accessing }
PotDS1307Device >> year [ 
	^self readRegister: 6
]

{ #category : #accessing }
PotDS1307Device >> year: anInt [
	self writeRegister: 6 data: anInt
]
