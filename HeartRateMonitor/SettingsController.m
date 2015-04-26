//
//  SettingsController.m
//  HeartRateMonitor
//
//  Created by Wouter Lemaire on 25/04/15.
//  Copyright (c) 2015 Wouter Lemaire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsController.h"


@interface SettingsController (){
    
}

@property (weak, nonatomic) IBOutlet UITextView *log;
@property (weak, nonatomic) IBOutlet UITextView *device;


@end

@implementation SettingsController {
    
}


- (void)viewDidLoad {
    
    //[[SharedController getSharedController] ];
    
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [self.device setText:idfv];
    
    self.deviceInfo.text = [NSString stringWithFormat:@"%@\n%@\n%@\n", [[SharedController getSharedController] connected], [[SharedController getSharedController] bodyData], [[SharedController getSharedController] manufacturer]];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    // Clear out textView
    [self.deviceInfo setText:@""];
    [self.deviceInfo setTextColor:[UIColor blueColor]];
    [self.deviceInfo setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [self.deviceInfo setFont:[UIFont fontWithName:@"Futura-CondensedMedium" size:25]];
    [self.deviceInfo setUserInteractionEnabled:NO];
    
    
}

- (IBAction)statusChanged:(id)sender {
    NSString * text = self.log.text;
    if ([self.Status isOn]) {
        
        [self.log setText:[@"Staat aan\n" stringByAppendingString:text]];
    
        //[self sendHeartRateToCloud];
    }else{
        [self.log setText:[@"Staat af\n" stringByAppendingString:text]];
        //[[[SharedController getSharedController] timer].invalidate];
        
        [[SharedController getSharedController] setTimer: nil];
        //appDelegate.viewCtrl.timer = nil;
    }
    [[SharedController getSharedController] setStatus:self.Status];
}


@end