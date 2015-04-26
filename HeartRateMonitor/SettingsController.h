//
//  SettingsController.h
//  HeartRateMonitor
//
//  Created by Wouter Lemaire on 25/04/15.
//  Copyright (c) 2015 Wouter Lemaire. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "SharedController.h"


@interface SettingsController : UIViewController {
    
}

// Properties for your Object controls
@property(nonatomic, readonly, retain) NSUUID *identifierForVendor;
@property (nonatomic, strong) IBOutlet UITextView  *deviceInfo;
@property (weak, nonatomic) IBOutlet UISwitch *Status;





@end
