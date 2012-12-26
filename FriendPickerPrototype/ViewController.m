//
//  ViewController.m
//  FriendPickerPrototype
//
//  Created by Andrew Vergara on 12/25/12.
//  Copyright (c) 2012 Super. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController () <FBFriendPickerDelegate, UISearchBarDelegate>

@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (retain, nonatomic) UISearchBar *searchBar;
@property (retain, nonatomic) NSString *searchText;

@end


@implementation ViewController

@synthesize friendPickerController = _friendPickerController;
@synthesize searchBar = _searchBar;
@synthesize searchText = _searchText;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStateChanged:) name: FBSessionStateChangedNotification object:nil];
    
    self.selectFriendsButton.hidden = YES;
}

- (void)viewDidUnload
{
    self.friendPickerController = nil;
    self.searchBar = nil;
}

#pragma mark - User Interaction Methods
- (IBAction)loginAction:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate openSessionWithAllowLoginUI:YES];
}

- (IBAction)selectFriendsAction:(id)sender
{
    if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Select Friends";
        self.friendPickerController.delegate = self;
    }
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection]; 
//    [self presentModalViewController:self.friendPickerController animated:YES];
    // This message will only work on iOS 5+. The completion handler is not implemented on iOS 4 and below.
    [self presentViewController:self.friendPickerController animated:YES completion:^(void){[self addSearchBarToFriendPickerView];}];
}

- (void)handlePickerDone
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Custom Facebook Select Friends Search Methods
- (void)addSearchBarToFriendPickerView
{
    if (self.searchBar == nil) {
        CGFloat searchBarHeight = 44.0;
        self.searchBar = [[UISearchBar alloc] initWithFrame: CGRectMake(0,0, self.view.bounds.size.width, searchBarHeight)];
        self.searchBar.autoresizingMask = self.searchBar.autoresizingMask | UIViewAutoresizingFlexibleWidth;
        self.searchBar.delegate = self;
        self.searchBar.showsCancelButton = YES;
        
        [self.friendPickerController.canvasView addSubview:self.searchBar];
        CGRect newFrame = self.friendPickerController.view.bounds;
        newFrame.size.height -= searchBarHeight;
        newFrame.origin.y = searchBarHeight;
        self.friendPickerController.tableView.frame = newFrame;
    }
}

- (void) handleSearch:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    self.searchText = searchBar.text;
    [self.friendPickerController updateView];
}

#pragma mark - UISearchBarDelegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    [self handleSearch:searchBar];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    self.searchText = nil;
    [searchBar resignFirstResponder];
}

#pragma mark - Facebook Session State Notification Methods
- (void)sessionStateChanged:(NSNotification*)notification {
    if (FBSession.activeSession.isOpen) {
        self.selectFriendsButton.hidden = NO;
        [self.loginButton setTitle:@"Logout" forState:UIControlStateNormal];
    } else {
        self.selectFriendsButton.hidden = YES;
        [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    }
}

#pragma mark - Facebook FBFriendPickerDelegate Methods
- (void)facebookViewControllerCancelWasPressed:(id)sender
{
    NSLog(@"Friend selection cancelled.");
    [self handlePickerDone];
}

- (void)facebookViewControllerDoneWasPressed:(id)sender
{
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        NSLog(@"Friend selected: %@", user.name);
    }
    [self handlePickerDone];
}

#pragma mark - Memory Warnings
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
