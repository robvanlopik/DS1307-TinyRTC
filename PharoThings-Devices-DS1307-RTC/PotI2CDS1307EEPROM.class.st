Class {
	#name : #PotI2CDS1307EEPROM,
	#superclass : #PotI2CDevice,
	#category : #'PharoThings-Devices-DS1307-RTC'
}

{ #category : #'instance creation' }
PotI2CDS1307EEPROM class >> defaultI2CAddress [
	"the eeprom on board of the TinyRTC"
	^16r50
]
