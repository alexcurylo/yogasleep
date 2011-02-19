//
//  TWNavigationAppDelegate.m
//
//  Copyright 2010 Trollwerks Inc. All rights reserved.
//

#import "TWNavigationAppDelegate.h"
#import "TWReachability.h"

@implementation TWNavigationAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize mainViewController;
@synthesize dataModel;
@synthesize noInternetAlert;

#pragma mark -
#pragma mark Life cycle

+ (void)initialize
{
	if ( self == [TWNavigationAppDelegate class])
   {
      /* if you'd like some settings defaults
		NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithBool:NO], kXXPrefDefaultValue,
         nil
      ];
		[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
       */
	}
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   (void)launchOptions;
   
   twlog("launched %@ %@(%@) with options %@",
      [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
      [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
      [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
      launchOptions
   );
  
   [self startReachabilityChecks];

   self.dataModel = [[[YSDataModel alloc] init] autorelease];

   // status bar marked hidden UIStatusBarStyleBlackOpaque in Info.plist so Default.png comes up fullscreen
   application.statusBarHidden = NO;
      
   [window addSubview:navigationController.view];
   [window makeKeyAndVisible];
   
   // return NO if URL in launchOptions cannot be handled
   return YES;
}

// only on iOS 4
- (void)applicationWillEnterForeground:(UIApplication *)application
{
   (void)application;
   twlog("applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
   (void)application;
   
   [self.dataModel updateManifest];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
   (void)application;
   twlog("applicationWillResignActive");
}

// only on iOS 4; may be quit without further notification
- (void)applicationDidEnterBackground:(UIApplication *)application
{
   (void)application;
   twlog("applicationDidEnterBackground");

   [self cleanup];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application;
// midnight, carrier time update, daylight savings time change
{
   (void)application;
   twlog("applicationSignificantTimeChange");
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
   (void)application;
   twlog("applicationDidReceiveMemoryWarning!! -- no action");
}

// only expected to be called on iOS 3, or iOS 4 on non-multitasking devices
- (void)applicationWillTerminate:(UIApplication *)application
{
   (void)application;
   twlog("applicationWillTerminate");
   
   [self cleanup];
}

- (void)cleanup
{
   [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)dealloc
{
	twrelease(navigationController);
	twrelease(mainViewController);
	twrelease(window);
	twrelease(dataModel);

	[super dealloc];
}

#pragma mark -
#pragma mark Application support

- (void)startReachabilityChecks
{
   // Observe the kReachabilityChangedNotification. When that notification is posted, the
   // method "reachabilityChanged" will be called. 
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
   
   //Change the host name here to change the server your monitoring
   hostReach = [[TWReachability reachabilityWithHostName: @"www.dropbox.com"] retain];
   [hostReach startNotifier];
   
   internetReach = [[TWReachability reachabilityForInternetConnection] retain];
   [internetReach startNotifier];
   
   wifiReach = [[TWReachability reachabilityForLocalWiFi] retain];
   [wifiReach startNotifier];
}

- (void)reachabilityChanged:(NSNotification *)note
{
   (void)note;
#if DEBUG
   TWReachability* curReach = [note object];
   NSParameterAssert([curReach isKindOfClass: [TWReachability class]]);
   
   NSString *reacher = @"unknown";
   NSString *status = @"unknown";
   
   if (curReach == hostReach) reacher = @"hostReach";
   else if (curReach == internetReach) reacher = @"internetReach";
   else if (curReach == wifiReach) reacher = @"wifiReach";

   switch (curReach.currentReachabilityStatus)
   {
      case kNotReachable: status = @"kNotReachable"; break;
      case kReachableViaWWAN: status = @"kReachableViaWWAN"; break;
      case kReachableViaWiFi: status = @"kReachableViaWiFi"; break;
      default: status = [NSString stringWithFormat:@"%d", curReach.currentReachabilityStatus]; break;
   }
   
   twlog("reachabilityChanged -- %@: %@", reacher, status);
#endif DEBUG
   
   //[self isInternetAvailable:YES];
}

- (BOOL)isInternetAvailable:(BOOL)alertIfNot
{
   BOOL result = NO;
   
   NetworkStatus internetStatus = [internetReach currentReachabilityStatus];
   switch (internetStatus)
   {
      default:
         twlog("isInternetAvailable unexpected internetStatus status %d!", internetStatus);
         // FALL
      case kNotReachable:
         result = NO;
         if (alertIfNot && !self.noInternetAlert)
         {
            self.noInternetAlert = [[[UIAlertView alloc]
                initWithTitle:NSLocalizedString(@"NOINTERNETTITLE", nil)
                message:NSLocalizedString(@"NOINTERNETMESSAGE", nil)
                delegate:self
                cancelButtonTitle:nil 
                otherButtonTitles:NSLocalizedString(@"OK", nil),
                nil
             ] autorelease];
            [self.noInternetAlert show];
         }
         break;
         
      case kReachableViaWWAN:
      case kReachableViaWiFi:
         result = YES;
         if (self.noInternetAlert)
            [self.noInternetAlert dismissWithClickedButtonIndex:0 animated:YES];
         self.noInternetAlert = nil;
         break;
   }
   
   return result;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
   (void)alertView;
   (void)buttonIndex;
   
   self.noInternetAlert = nil;
   
}

#pragma mark -
#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
   if (viewController == (id)self.mainViewController)
   {
      //navController.navigationBar.hidden = YES;
      [navController setNavigationBarHidden:YES animated:animated];
   }
   else
   {
      [navController setNavigationBarHidden:NO animated:animated];
   }
}

@end

#pragma mark -
#pragma mark Conveniences

TWNavigationAppDelegate *TWAppDelegate(void)
{
   return (TWNavigationAppDelegate *)[[UIApplication sharedApplication] delegate];
}

YSDataModel *TWDataModel(void)
{
   return TWAppDelegate().dataModel;
}
