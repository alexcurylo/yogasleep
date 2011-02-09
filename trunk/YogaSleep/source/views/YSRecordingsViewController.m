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

   if (TWDataModel().hasCustomPlaylists)
      self.navigationItem.rightBarButtonItem = self.editButtonItem;
   else 
      self.navigationItem.rightBarButtonItem = nil;
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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
   [super setEditing:editing animated:animated];
   [self.recordingsTable setEditing:editing animated:animated];
}


#pragma mark -
#pragma mark Table support

- (NSArray *)recordingsList
{
   return TWDataModel().playlists;
}

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
   
   return self.recordingsList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   (void)tableView;
   
   CGFloat rowHeight = kStandardCellHeight;
   
   NSDictionary *playlist = [self.recordingsList objectAtIndex:indexPath.row];
   NSString *name = [playlist objectForKey:kPlaylistName];
   UIFont *nameFont = [UIFont boldSystemFontOfSize:kCellNameSize];
   NSInteger numberOfLines = ceilf([name sizeWithFont:nameFont constrainedToSize:CGSizeMake(kCellNameStandardWidth, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap].height/20.0);
   if (2 < numberOfLines)
      rowHeight += (numberOfLines - 2) * kExtraLineHeight;
      
   return rowHeight;
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
   
   //[cell fillOutWithPlaylist:indexPath.row];
   NSDictionary *playlist = [self.recordingsList objectAtIndex:indexPath.row];
   [cell fillOutWithPlaylist:playlist];

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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
   (void)tableView;
   
   NSDictionary *playlist = [self.recordingsList objectAtIndex:indexPath.row];

   BOOL editable = [[playlist objectForKey:kPlaylistEditable] boolValue];
   return editable ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
   /*
   switch (indexPath.section)
   {
      default:
         twlog("what section is %d?", indexPath.section);
         return UITableViewCellEditingStyleNone;
          case kSectionCustomPlaylist:
          return UITableViewCellEditingStyleDelete;
      case kSectionAddableTracks:
         return UITableViewCellEditingStyleInsert;
   }
    */
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (UITableViewCellEditingStyleDelete != editingStyle)
      return;
   
   NSDictionary *playlist = [self.recordingsList objectAtIndex:indexPath.row];
   [TWDataModel() removePlaylist:playlist];
   [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];

   if (!TWDataModel().hasCustomPlaylists)
   {
      self.navigationItem.rightBarButtonItem = nil;
      
      if (self.isEditing)
         [self setEditing:NO animated:YES];
   }
}

@end

