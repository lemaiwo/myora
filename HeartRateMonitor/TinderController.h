//
//  TinderController.h
//  HeartRateMonitor
//
//  Created by Wouter Lemaire on 26/04/15.
//  Copyright (c) 2015 Wouter Lemaire. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedController.h"

@interface TinderController : UIViewController {
    
}

// Properties for your Object controls

-(void)getQuestionsFromCloud;

-(void)sendAnswerToCloud:(NSString *)answer;




@end
