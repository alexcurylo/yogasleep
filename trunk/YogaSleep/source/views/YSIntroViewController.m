//
//  YSIntroViewController.m
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

#import "YSIntroViewController.h"

@implementation YSIntroViewController

@synthesize display;

#pragma mark -
#pragma mark Life cycle

+ (YSIntroViewController *)controller
{
   YSIntroViewController *controller = [[[YSIntroViewController alloc] initWithNibName:@"YSIntroView" bundle:nil] autorelease];
   controller.title = NSLocalizedString(@"TITLEINTRO", nil);
   return controller;
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"introduction" ofType:@"html"];
   NSData *displayData = [NSData dataWithContentsOfFile:dataPath];
   [self.display loadData:displayData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];

   //self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];
   //[TWAppDelegate() showIntroAlert:@"INTROBLANK"];
}

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
   
   twlog("YSIntroViewController didReceiveMemoryWarning -- no action");
}

- (void)viewDidUnload
{
   twlog("YSIntroViewController viewDidUnload");
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
   self.display = nil;
}

- (void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   twrelease(display);
   
   [super dealloc];
}

#pragma mark -
#pragma mark Actions


@end
