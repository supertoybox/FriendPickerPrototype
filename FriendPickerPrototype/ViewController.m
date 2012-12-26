//
//  ViewController.m
//  FriendPickerPrototype
//
//  Created by Andrew Vergara on 12/25/12.
//  Copyright (c) 2012 Super. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStateChanged:) name: FBSessionStateChangedNotification object:nil];
}

#pragma mark - User Interaction Methods
- (IBAction)loginDidTouch:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate openSessionWithAllowLoginUI:YES];
}

#pragma mark - Facebook Session State Notification Methods
- (void)sessionStateChanged:(NSNotification*)notification {
    if (FBSession.activeSession.isOpen) {
        [self.loginButton setTitle:@"Logout" forState:UIControlStateNormal];
    } else {
        [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    }
}


#pragma mark - Memory Warnings
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
