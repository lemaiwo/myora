//
//  PageController.m
//  HeartRateMonitor
//
//  Created by Wouter Lemaire on 25/04/15.
//  Copyright (c) 2015 Wouter Lemaire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PageController.h"
@implementation PageController
{
    NSArray *myViewControllers;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
    self.dataSource = self;
    
    UIViewController *p1 = [self.storyboard
                            instantiateViewControllerWithIdentifier:@"SettingsView"];
    UIViewController *p2 = [self.storyboard
                            instantiateViewControllerWithIdentifier:@"PulseMonitorView"];
    UIViewController *p3 = [self.storyboard
                            instantiateViewControllerWithIdentifier:@"TinderView"];
    UIViewController *p4 = [self.storyboard
                            instantiateViewControllerWithIdentifier:@"DashBoardView"];
    
    myViewControllers = @[p1,p2,p3,p4];
    
    [self setViewControllers:@[p1]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO completion:nil];
    
    NSLog(@"loaded!");
}

-(UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    return myViewControllers[index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
     viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger currentIndex = [myViewControllers indexOfObject:viewController];
    // get the index of the current view controller on display
    
    if (currentIndex > 0)
    {
        return [myViewControllers objectAtIndex:currentIndex-1];
        // return the previous viewcontroller
    } else
    {
        return nil;
        // do nothing
    }
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger currentIndex = [myViewControllers indexOfObject:viewController];
    // get the index of the current view controller on display
    // check if we are at the end and decide if we need to present
    // the next viewcontroller
    if (currentIndex < [myViewControllers count]-1)
    {
        return [myViewControllers objectAtIndex:currentIndex+1];
        // return the next view controller
    } else
    {
        return nil;
        // do nothing
    }
}
-(NSInteger)presentationCountForPageViewController:
(UIPageViewController *)pageViewController
{
    return myViewControllers.count;
}

-(NSInteger)presentationIndexForPageViewController:
(UIPageViewController *)pageViewController
{
    return 0;
}
@end