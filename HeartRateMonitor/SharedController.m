//
//  SharedController.m
//  GameBase1
//
//  Created by Wouter Lemaire on 15/09/13.
//  Copyright (c) 2013 Wouter Lemaire. All rights reserved.
//

#import "SharedController.h"

static SharedController *sharedController;

@implementation SharedController

//Settingscontroller
@synthesize Status;
@synthesize connected;
@synthesize bodyData;
@synthesize manufacturer;
@synthesize deviceInfo;

//ViewController
@synthesize timer;
@synthesize multiHalo;

+(SharedController *)getSharedController{
    if(!sharedController){
        sharedController = [[SharedController alloc] init];
    }
    return sharedController;
}

@end
