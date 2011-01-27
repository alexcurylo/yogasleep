//
//  TWNavigationAppDelegate.h
//
//  Copyright 2010 Trollwerks Inc. All rights reserved.
//

#import "YSDataModel.h"

@class YSMainViewController;

@interface TWNavigationAppDelegate : NSObject <
   UIApplicationDelegate,
   UINavigationControllerDelegate
>
{
   IBOutlet UIWindow *window;
   IBOutlet UINavigationController *navigationController;
   IBOutlet YSMainViewController *mainViewController;

   YSDataModel *dataModel;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet YSMainViewController *mainViewController;
@property (nonatomic, retain) YSDataModel *dataModel;

#pragma mark -
#pragma mark Life cycle

+ (void)initialize;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationSignificantTimeChange:(UIApplication *)application;
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application;
- (void)applicationWillTerminate:(UIApplication *)application;
- (void)cleanup;
- (void)dealloc;

#pragma mark -
#pragma mark Application support

#pragma mark -
#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end

#pragma mark -
#pragma mark Conveniences

TWNavigationAppDelegate *TWAppDelegate(void);
YSDataModel *TWDataModel(void);
