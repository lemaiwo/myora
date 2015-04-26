//
//  SharedController.h
//  GameBase1
//
//  Created by Wouter Lemaire on 15/09/13.
//  Copyright (c) 2013 Wouter Lemaire. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SettingsController.h"
#import "ViewController.h"
#import "MultiplePulsingHaloLayer.h"

@interface SharedController : NSObject

//SettingController
@property (weak, nonatomic) IBOutlet UISwitch *Status;
@property (nonatomic, strong) NSString   *connected;
@property (nonatomic, strong) NSString   *bodyData;
@property (nonatomic, strong) NSString   *manufacturer;
@property (nonatomic, strong) IBOutlet UITextView  *deviceInfo;

//Viewcontroller
@property (strong) NSTimer *timer;
@property (nonatomic, weak) MultiplePulsingHaloLayer *multiHalo;


+ (SharedController*)getSharedController;

@end
