//
//  YSMainViewController.m
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

#import "YSMainViewController.h"
#import "YSIntroViewController.h"
#import "YSMoreInfoViewController.h"
#import "YSRecordingsViewController.h"
//#import "YSCreateViewController.h"
#import "YSCustomRecordingsViewController.h"
#import "TWNavigationAppDelegate.h"

@implementation YSMainViewController

#pragma mark -
#pragma mark Life cycle

+ (YSMainViewController *)controller
{
   YSMainViewController *controller = [[[YSMainViewController alloc] initWithNibName:@"YSMainView" bundle:nil] autorelease];
   //self.title = NSLocalizedString(@"BLANK", nil);
   return controller;
}

- (void)viewDidLoad
{
   [super viewDidLoad];

   /*
   // Handle Audio Remote Control events (only available under iOS 4)
	if ([[UIApplication sharedApplication] respondsToSelector:@selector(beginReceivingRemoteControlEvents)])
   {
		[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
      // (NB. Controller will have to becomeFirstResponder and implement -remoteControlReceivedWithEvent)
   }
    */
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
   
   /*
   // This is necessary in order to get notified of the Audio Remote Control events
   [self becomeFirstResponder];
    */
}

- (void)viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];
   //[TWAppDelegate() showIntroAlert:@"INTROBLANK"];
}

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
   
   twlog("YSMainViewController didReceiveMemoryWarning -- no action");
}

- (void)viewDidUnload
{
   twlog("YSMainViewController viewDidUnload");
	[self clearOutlets];
}

- (void)setView:(UIView *)toView
{
	if (!toView)
		[self clearOutlets];
	
	[super setView:toView];
}

- (void)clearOutlets
{
}

- (void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   
   [super dealloc];
}

#pragma mark -
#pragma mark Actions

// control event handling
/*
- (BOOL)canBecomeFirstResponder
{
   return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
	twlog("UIEventTypeRemoteControl: %d - %d", event.type, event.subtype);
	
	if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause)
   {
		twlog("UIEventSubtypeRemoteControlTogglePlayPause");
      [TWDataModel() togglePlayPause];
	}
	if (event.subtype == UIEventSubtypeRemoteControlPlay)
   {
		twlog("UIEventSubtypeRemoteControlPlay");
      [TWDataModel() play:TWDataModel().playingPlaylist];
	}
	if (event.subtype == UIEventSubtypeRemoteControlPause)
   {
		twlog("UIEventSubtypeRemoteControlPause");
      [TWDataModel() pause:TWDataModel().playingPlaylist];
	}
	if (event.subtype == UIEventSubtypeRemoteControlStop)
   {
		twlog("UIEventSubtypeRemoteControlStop");
      [TWDataModel() pause:TWDataModel().playingPlaylist];
	}
	if (event.subtype == UIEventSubtypeRemoteControlNextTrack)
   {
		twlog("UIEventSubtypeRemoteControlNextTrack");
      [TWDataModel() nextTrack];
	}
	if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack)
   {
		twlog("UIEventSubtypeRemoteControlPreviousTrack");
      [TWDataModel() previousTrack];
	}
}
*/

- (IBAction)showIntro:(id)sender
{
   (void)sender;
   
   [self.navigationController pushViewController:[YSIntroViewController controller] animated:YES];
}

- (IBAction)showRecordings:(id)sender
{
   (void)sender;
   
   [self.navigationController pushViewController:[YSRecordingsViewController controller] animated:YES];
}

- (IBAction)showCreate:(id)sender
{
   (void)sender;
   
   //[self.navigationController pushViewController:[YSCreateViewController controller] animated:YES];
   [self.navigationController pushViewController:[YSCustomRecordingsViewController controller] animated:YES];
}

- (IBAction)showMoreInfo:(id)sender
{
   (void)sender;

   [self.navigationController pushViewController:[YSMoreInfoViewController controller] animated:YES];
}

@end
