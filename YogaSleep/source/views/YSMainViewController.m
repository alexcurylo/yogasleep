//
//  YSMainViewController.m
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

#import "YSMainViewController.h"
#import "YSIntroViewController.h"
#import "YSMoreInfoViewController.h"
#import "YSRecordingsViewController.h"
#import "YSCreateViewController.h"

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
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
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
   
   [self.navigationController pushViewController:[YSCreateViewController controller] animated:YES];
}

- (IBAction)showMoreInfo:(id)sender
{
   (void)sender;

   [self.navigationController pushViewController:[YSMoreInfoViewController controller] animated:YES];
}

@end
