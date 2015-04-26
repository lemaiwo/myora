//
//  TinderController.m
//  HeartRateMonitor
//
//  Created by Wouter Lemaire on 26/04/15.
//  Copyright (c) 2015 Wouter Lemaire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TinderController.h"



@interface TinderController (){
    
}

@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;
@property (weak, nonatomic) IBOutlet UITextView *questionView;
@property (nonatomic) int questionId;


@end

@implementation TinderController {
   
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    [self getQuestionsFromCloud];
    
    
    
     }

- (IBAction)yesButtonPressed:(id)sender {
    [self sendAnswerToCloud:@"true"];
}
- (IBAction)noButtonPressed:(id)sender {
    [self sendAnswerToCloud:@"false"];
}


-(void)getQuestionsFromCloud{

 NSString * urlBaseString = [NSString stringWithFormat:@"https://heartrates0007035481trial.hanatrial.ondemand.com/HeartRateMonitor/?action=getquestion"];
    
    
    NSURL *url = [NSURL URLWithString:urlBaseString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    //NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    //create request
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * mydata = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    
    if (mydata) {
        
        NSError *localError = nil;
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:mydata options:0 error:&localError];
        
        if (localError != nil) {
            NSLog(@"Parsing Error");
        }
        NSArray *results = [parsedObject valueForKey:@"id"];
        
        
    }

}

-(void)sendAnswerToCloud:(NSString *)answer {
    
    NSString * urlBaseString = [NSString stringWithFormat:@"https://heartrates0007035481trial.hanatrial.ondemand.com/HeartRateMonitor/?"];
    
    //unique identifier
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    //timestamp
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    
    //NSString *answer = @"";
    
    
    
    //construct url
    NSString * urlActionString =
    [NSString stringWithFormat:
     @"action=addAswer&deviceid=%@&sendat=%@.000&question=%i&answer=%@",
     idfv,
     dateString,
     self.questionId,
     answer
     ];
    
    urlActionString = [urlActionString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString * urlString = [NSString stringWithFormat: @"%@%@", urlBaseString , urlActionString];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    //create request
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (error)
         {
             NSLog(@"Error,%@", [error localizedDescription]);
             //[self.log setText:[@"Error\n" stringByAppendingString:text]];
         }
         else
         {
             NSLog(@"OK ");
             //NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
             //[self.log setText:[@"Verzonden\n" stringByAppendingString:text]];
         }
     }];
    
    
}


@end