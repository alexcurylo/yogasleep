//
//  YSMoreInfoViewController.h
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

@interface YSMoreInfoViewController : UIViewController
{
   IBOutlet UIWebView *display;
}

@property (nonatomic, retain) IBOutlet UIWebView *display;

#pragma mark -
#pragma mark Life cycle

+ (YSMoreInfoViewController *)controller;

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

@end
