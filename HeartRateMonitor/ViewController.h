//
//  ViewController.h
//  HeartRateMonitor
//
//  Created by Wouter Lemaire on 18/01/15.
//  Copyright (c) 2015 Wouter Lemaire. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "SharedController.h"


#include <AudioToolbox/AudioToolbox.h>

#define POLARH7_HRM_DEVICE_INFO_SERVICE_UUID @"180A"       // 180A = Device Information
#define POLARH7_HRM_HEART_RATE_SERVICE_UUID @"180D"        // 180D = Heart Rate Service
#define POLARH7_HRM_ENABLE_SERVICE_UUID @"2A39"
#define POLARH7_HRM_NOTIFICATIONS_SERVICE_UUID @"2A37"
#define POLARH7_HRM_BODY_LOCATION_UUID @"2A38"
#define POLARH7_HRM_MANUFACTURER_NAME_UUID @"2A29"

@interface ViewController : UIViewController<CBCentralManagerDelegate,CBPeripheralDelegate>{
    

    AVAudioPlayer *myAudioPlayer;
    

}
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral     *polarH7HRMPeripheral;
@property (strong) NSTimer *timer;

// Properties for your Object controls


// Properties to hold data characteristics for the peripheral device
@property (nonatomic, strong) NSString   *connected;
@property (nonatomic, strong) NSString   *bodyData;
@property (nonatomic, strong) NSString   *manufacturer;
@property (nonatomic, strong) NSString   *polarH7DeviceData;
@property (assign) uint16_t heartRate;

// Properties to handle storing the BPM and heart beat
//@property (nonatomic, strong) UILabel    *heartRateBPM;
@property (nonatomic, retain) NSTimer    *pulseTimer;

// Properties for the music
@property (nonatomic, retain) AVAudioPlayer *myAudioPlayer;



-(void)sendHeartRateToCloud;

// Instance method to get the heart rate BPM information
- (void) getHeartBPMData:(CBCharacteristic *)characteristic error:(NSError *)error;

// Instance methods to grab device Manufacturer Name, Body Location
- (void) getManufacturerName:(CBCharacteristic *)characteristic;
- (void) getBodyLocation:(CBCharacteristic *)characteristic;

//Instance method to start the monitor
- (void) startMonitor;

// Instance method to perform heart beat animations
- (void) doHeartBeat;

@end

