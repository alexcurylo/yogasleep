//
//  YSRecordingsViewController.m
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

#import "YSRecordingsViewController.h"
#import "TWNavigationAppDelegate.h"
#import "YSRecordingViewController.h"
#import "YSRecordingTableViewCell.h"

@implementation YSRecordingsViewController

@synthesize moreInfo;
@synthesize recordingsTable;
@synthesize templateCell;

#pragma mark -
#pragma mark Life cycle

+ (YSRecordingsViewController *)controller
{
   YSRecordingsViewController *controller = [[[YSRecordingsViewController alloc] initWithNibName:@"YSRecordingsView" bundle:nil] autorelease];
   controller.title = NSLocalizedString(@"TITLERECORDINGS", nil);
   return controller;
}

- (void)viewDidLoad
{
   [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
   
	NSIndexPath *selection = [self.recordingsTable indexPathForSelectedRow];
	if (selection)
		[self.recordingsTable deselectRowAtIndexPath:selection animated:YES];
   
   // for now we're treating it as a fixed instruction
   //self.moreInfo.text = NSLocalizedString(@"INFORECORDING", nil);
}

- (void)viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];
   //[TWAppDelegate() showIntroAlert:@"INTROTABLE"];
}

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];

   twlog("YSRecordingsViewController didReceiveMemoryWarning -- no action");
}

- (void)viewDidUnload
{
   twlog("YSRecordingsViewController viewDidUnload");
	[self clearOutlets];
}

- (void)setView:(UIView*)toView
{
	if (!toView)
		[self clearOutlets];
	
	[super setView:toView];
}

- (void)clearOutlets
{
   self.moreInfo = nil;
   self.recordingsTable = nil;
}

- (void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   
   twrelease(moreInfo);
   twrelease(recordingsTable);

   [super dealloc];
}

#pragma mark -
#pragma mark Actions


#pragma mark -
#pragma mark Table support

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	(void)tableView;
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	(void)tableView;
	(void)section;
	
   return nil; //@"Untitled Section";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   (void)tableView;
 	(void)section;
   
   return TWDataModel().playlists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // note that identifier in nib must match
    static NSString *kRecordingsViewCellIdentifier = @"RecordingCell";
    
    YSRecordingTableViewCell *cell = (YSRecordingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kRecordingsViewCellIdentifier];
    if (cell == nil)
    {
      //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kRecordingsViewCellIdentifier] autorelease];
      //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

       [[NSBundle mainBundle] loadNibNamed:@"YSRecordingCell" owner:self options:nil];
       twcheck(self.templateCell);
       cell = self.templateCell;
       self.templateCell = nil;
    }
   /*
   if (1 & indexPath.row)
      cell.backgroundView.backgroundColor = [UIColor colorFromHexValue:0xE0E0E0];
   else
      cell.backgroundView.backgroundColor = [UIColor colorFromHexValue:0xF2F2F2];
   */
   
   [cell fillOutWithPlaylist:indexPath.row];

   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 	(void)tableView;

   [self tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
 	(void)tableView;

   [self.navigationController pushViewController:[YSRecordingViewController controllerForRecording:indexPath.row] animated:YES];
}

@end

