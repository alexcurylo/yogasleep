//
//  YSMainViewController.h
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

@interface YSMainViewController : UIViewController
{
}

#pragma mark -
#pragma mark Life cycle

+ (YSMainViewController *)controller;

- (void)viewDidLoad;
- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)didReceiveMemoryWarning;
- (void)viewDidUnload;
- (void)setView:(UIView *)toView;
- (void)clearOutlets;
- (void)dealloc;

#pragma mark -
#pragma mark Actions

/*
- (BOOL)canBecomeFirstResponder;
- (void)remoteControlReceivedWithEvent:(UIEvent *)event;
*/

- (IBAction)showIntro:(id)sender;
- (IBAction)showRecordings:(id)sender;
- (IBAction)showCreate:(id)sender;
- (IBAction)showMoreInfo:(id)sender;

@end
