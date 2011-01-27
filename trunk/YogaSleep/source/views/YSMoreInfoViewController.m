//
//  YSMoreInfoViewController.m
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

#import "YSMoreInfoViewController.h"

@implementation YSMoreInfoViewController

@synthesize display;

#pragma mark -
#pragma mark Life cycle

+ (YSMoreInfoViewController *)controller
{
   YSMoreInfoViewController *controller = [[[YSMoreInfoViewController alloc] initWithNibName:@"YSMoreInfoView" bundle:nil] autorelease];
   controller.title = NSLocalizedString(@"TITLEMOREINFO", nil);
   return controller;
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"moreinfo" ofType:@"html"];
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
   
   twlog("YSMoreInfoViewController didReceiveMemoryWarning -- no action");
}

- (void)viewDidUnload
{
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
