//
//  YSMoreInfoViewController.h
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

#import <MessageUI/MessageUI.h>

@interface YSMoreInfoViewController : UIViewController <
   UIWebViewDelegate,
   MFMailComposeViewControllerDelegate
>
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

- (void)sendMailWithURL:(NSURL *)url;
- (void)sendEmailWithSubject:(NSString *)subject body:(NSString *)body to:(NSString *)toPerson cc:(NSString *)ccPerson;
// MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;

#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;

@end
