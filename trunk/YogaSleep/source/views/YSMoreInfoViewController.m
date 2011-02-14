//
//  YSMoreInfoViewController.m
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

#import "YSMoreInfoViewController.h"
#import "TWNavigationAppDelegate.h"
#import "TWXUIAlertView.h"

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
   
   //NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"moreinfo" ofType:@"html"];
   NSString *dataPath = [TWDataModel() pathForUpdatableFile:@"moreinfo.html"];
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

// http://blog.coriolis.ch/2009/10/29/extend-uiwebview-to-handle-all-special-links/
- (void)sendMailWithURL:(NSURL *)url
{
	// method to split an url "mailto:sburlot@coriolis.ch?cc=info@coriolis.ch&subject=Hello%20From%20iPhone&body=The message's first paragraph.%0A%0aSecond paragraph.%0A%0AThird Paragraph."
	// into separate elements
   
	NSString *toPerson = @"";
	NSString *ccPerson = @"";;
	NSString *subject = @"";
	NSString *body = @"";
   
	NSMutableString *urlString = [NSMutableString stringWithString:[url absoluteString]];
	[urlString replaceOccurrencesOfString:@"mailto:" withString:@"" options:0 range:NSMakeRange(0, [urlString length])];
	
	if ([urlString rangeOfString:@"?"].location != NSNotFound) {
		toPerson = [[urlString componentsSeparatedByString:@"?"] objectAtIndex:0];
		NSString *query = [[urlString componentsSeparatedByString:@"?"] objectAtIndex:1];
		
		if (query && [query length]) {
			NSArray *itemsOfURL = [query componentsSeparatedByString:@"&"];
			for (NSString *queryItem in itemsOfURL) {
				NSArray *queryElements = [queryItem componentsSeparatedByString:@"="];
				//twlog("queryElements: %@", queryElements);
				if ([[queryElements objectAtIndex:0] isEqualToString:@"to"])
					toPerson = [[queryElements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				if ([[queryElements objectAtIndex:0] isEqualToString:@"cc"])
					ccPerson = [[queryElements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				if ([[queryElements objectAtIndex:0] isEqualToString:@"subject"])
					subject = [[queryElements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				if ([[queryElements objectAtIndex:0] isEqualToString:@"body"])
					body = [[queryElements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			}
		}
	} else {
		toPerson = urlString;
	}
   
	//twlog("to: %@", toPerson);
	//twlog("cc: %@", ccPerson);
	//twlog("subject: %@", subject);
	//twlog("body: %@", body);
	[self sendEmailWithSubject:subject body:body to:toPerson cc:ccPerson];
}

- (void)sendEmailWithSubject:(NSString *)subject body:(NSString *)body to:(NSString *)toPerson cc:(NSString *)ccPerson
{
	if (![MFMailComposeViewController canSendMail])
   {
      [UIAlertView twxOKAlert:@"SORRY" withMessage:@"NOEMAIL"];
		return;
	}
	
   MFMailComposeViewController *picker = [[[MFMailComposeViewController alloc] init] autorelease];
	picker.mailComposeDelegate = self;
	
	[picker setToRecipients:[NSArray arrayWithObject:toPerson]];
	[picker setCcRecipients:[NSArray arrayWithObject:ccPerson]];
	[picker setSubject:subject];
	[picker setMessageBody:body isHTML:NO];
   picker.navigationBar.barStyle = UIBarStyleBlack;

	[self presentModalViewController:picker animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
   (void)controller;
   (void)error;
   
	switch (result)
	{
		case MFMailComposeResultCancelled:
		case MFMailComposeResultSaved:
		case MFMailComposeResultSent:
			break;
		case MFMailComposeResultFailed:
		default:
         [UIAlertView twxOKAlert:@"SORRY" withMessage:@"EMAILFAIL"];
			break;
	}
	[self dismissModalViewControllerAnimated:YES];	
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
   (void)webView;
   (void)navigationType;

   if ([request.URL.scheme isEqual:@"mailto"])
   {
		[self sendMailWithURL:request.URL];
      return NO;
   }
   return YES;
}

@end
