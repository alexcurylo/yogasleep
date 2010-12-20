//
//  YSCreateViewController.m
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

#import "YSCreateViewController.h"
#import "TWNavigationAppDelegate.h"
#import "YSRecordingTableViewCell.h"

@implementation YSCreateViewController

@synthesize moreInfo;
@synthesize createTable;
@synthesize templateCell;
@synthesize playlist;

#pragma mark -
#pragma mark Life cycle

+ (YSCreateViewController *)controller
{
   YSCreateViewController *controller = [[[YSCreateViewController alloc] initWithNibName:@"YSCreateView" bundle:nil] autorelease];
   controller.playlist = TWDataModel().customPlaylist;
   controller.title = NSLocalizedString(@"TITLECREATE", nil);
   return controller;
}

- (void)viewDidLoad
{
   [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
   
   [self.createTable setEditing:YES animated:NO];
   
   [[NSNotificationCenter defaultCenter] addObserver:self
      selector:@selector(trackChanged:)
      name:kTrackChangeNotification
      object:nil
    ];
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
   
	NSIndexPath *selection = [self.createTable indexPathForSelectedRow];
	if (selection)
		[self.createTable deselectRowAtIndexPath:selection animated:YES];
   
   //NSString *description = [self.playlist objectForKey:kPlaylistDescription];
   //self.moreInfo.text = description;
   
   [self fixPlayControls];
}

- (void)viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];
   //[TWAppDelegate() showIntroAlert:@"INTROTABLE"];
}

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];

   twlog("YSCreateViewController didReceiveMemoryWarning -- no action");
}

- (void)viewDidUnload
{
   twlog("YSCreateViewController viewDidUnload");
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
   self.createTable = nil;
}

- (void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   
   twrelease(moreInfo);
   twrelease(createTable);
   twrelease(playlist);
 
   [super dealloc];
}

#pragma mark -
#pragma mark Actions


- (void)fixPlayControls
{
   NSString *imageName = nil;
   SEL action = nil;
   BOOL playing = [TWDataModel() isPlayingPlaylist:self.playlist];
   if (playing)
   {
      imageName = @"Pause 32x32.png";
      action = @selector(pause);
   }
   else
   {
      imageName = @"Play 32x32.png"; 
      action = @selector(play);
   }
   UIBarButtonItem *barButtonItem = [[[UIBarButtonItem alloc]
      initWithImage:[UIImage imageNamed:imageName]
      style:UIBarButtonItemStyleBordered
      target:self
      action:action
   ] autorelease];
   self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (void)play
{
   [TWDataModel() play:self.playlist];
   
   [self fixPlayControls];
   [self.createTable reloadData];
}

- (void)pause
{
   [TWDataModel() pause:self.playlist];
   
   [self fixPlayControls];
}

- (void)trackChanged:(NSNotification *)note
{
   (void)note;
	
   [self fixPlayControls];
   [self.createTable reloadData];
}

- (void)addTrack:(NSIndexPath *)indexPath
{
   NSDictionary *track = [TWDataModel().tracks objectAtIndex:indexPath.row];

   // add track ID to components
   NSString *trackID = [track objectForKey:kTrackID];
   NSMutableArray *components = [self.playlist objectForKey:kPlaylistComponents];
   [components addObject:trackID];
   
   // add track time to playlist time
   NSInteger trackSeconds = [[track objectForKey:kTrackTime] integerValue];
   NSInteger totalSeconds = [[self.playlist objectForKey:kPlaylistTime] integerValue];
   totalSeconds += trackSeconds;
   [self.playlist setObject:[NSNumber numberWithInteger:totalSeconds] forKey:kPlaylistTime];
   
   // update model and UI
   [TWDataModel() setCustomPlaylist:self.playlist];
   //[self.createTable reloadData];
   // any call to the commented out bits crashes ... why?
   //[self.createTable beginUpdates];
   //[self.createTable insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
   [self.createTable reloadData];
   //[self.createTable endUpdates];
}

- (void)removeTrack:(NSIndexPath *)indexPath
{
   // remove track from components, after we get its time
   NSMutableArray *components = [self.playlist objectForKey:kPlaylistComponents];
   NSString *trackID = [components objectAtIndex:indexPath.row];
   NSDictionary *track = [TWDataModel() trackWithID:trackID];
   NSInteger trackSeconds = [[track objectForKey:kTrackTime] integerValue];
   [components removeObjectAtIndex:indexPath.row];
   
   // remove track time from playlist time
   NSInteger totalSeconds = [[self.playlist objectForKey:kPlaylistTime] integerValue];
   totalSeconds -= trackSeconds;
   [self.playlist setObject:[NSNumber numberWithInteger:totalSeconds] forKey:kPlaylistTime];
   
   // update model and UI
   [TWDataModel() setCustomPlaylist:self.playlist];
   //[self.createTable reloadData];
   [self.createTable beginUpdates];
   [self.createTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
   [self.createTable reloadData];
   [self.createTable endUpdates];
}

- (void)moveTrack:(NSInteger)idx to:(NSInteger)newIdx
{
   NSMutableArray *components = [self.playlist objectForKey:kPlaylistComponents];
   NSString *trackID = [components objectAtIndex:idx];
   [components removeObjectAtIndex:idx];
   [components insertObject:trackID atIndex:newIdx];
 
   // update model, UI handles itself
   [TWDataModel() setCustomPlaylist:self.playlist];
}

#pragma mark -
#pragma mark Table support

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	(void)tableView;
    return kCreateSectionsCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	(void)tableView;
	
   NSString *sectionTitle = nil;
   switch (section)
   {
      default:
         twlog("what section is %d?", section);
      case kSectionCustomPlaylist:
         {
         NSInteger seconds = [[self.playlist objectForKey:kPlaylistTime] integerValue];
         sectionTitle = [NSString stringWithFormat:NSLocalizedString(@"CREATELISTHEADER", nil),
            seconds / 60,
            seconds % 60
         ];
         }
         break;
      case kSectionAddableTracks:
         sectionTitle = NSLocalizedString(@"CREATETRACKSHEADER", nil);
         break;
   }
   
   return sectionTitle;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   (void)tableView;

   NSInteger rows = 0;
   switch (section)
   {
      default:
         twlog("what section is %d?", section);
      case kSectionCustomPlaylist:
         {
         NSArray *components = [self.playlist objectForKey:kPlaylistComponents];
         rows = components.count;
         }
         break;
      case kSectionAddableTracks:
         rows = TWDataModel().tracks.count;
         break;
   }
   
   return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   // note that identifier in nib must match
   static NSString *kCreateViewCellIdentifier = @"RecordingCell";
    
   YSRecordingTableViewCell *cell = (YSRecordingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kCreateViewCellIdentifier];
    if (cell == nil)
    {
      //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCreateViewCellIdentifier] autorelease];
      //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
       
       [[NSBundle mainBundle] loadNibNamed:@"YSCreateCell" owner:self options:nil];
       twcheck(self.templateCell);
       cell = self.templateCell;
       self.templateCell = nil;
       
       //cell.accessoryType = UITableViewCellAccessoryNone;
    }
   /*
    if (1 & indexPath.row)
    cell.backgroundView.backgroundColor = [UIColor colorFromHexValue:0xE0E0E0];
    else
    cell.backgroundView.backgroundColor = [UIColor colorFromHexValue:0xF2F2F2];
    */

   switch (indexPath.section)
   {
      default:
         twlog("what section is %d?", indexPath.section);
      case kSectionCustomPlaylist:
         [cell fillOutWithTrack:indexPath.row fromPlaylist:self.playlist];
         break;
      case kSectionAddableTracks:
         [cell fillOutWithDataModelTrack:indexPath.row];
        break;
   }
   
   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 	(void)tableView;

   // Navigation logic may go here -- for example, create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController animated:YES];
	// [anotherViewController release];
   
   // or treat it as an accessory tap perhaps
   // [self tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
   
   twlog("selected row %i", indexPath.row);
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
 	(void)tableView;

   twlog("accessory button tapped for row %i", indexPath.row);
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
   (void)tableView;
   
   switch (indexPath.section)
   {
      default:
         twlog("what section is %d?", indexPath.section);
      case kSectionCustomPlaylist:
         return UITableViewCellEditingStyleDelete;
      case kSectionAddableTracks:
         return UITableViewCellEditingStyleInsert;
   }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
   (void)tableView;
   (void)editingStyle;
   
   switch (indexPath.section)
   {
      default:
         twlog("what section is %d?", indexPath.section);
      case kSectionCustomPlaylist:
         [self removeTrack:indexPath];
         break;
      case kSectionAddableTracks:
         [self addTrack:indexPath];
         break;
   }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
   (void)tableView;
   
   switch (indexPath.section)
   {
      default:
         twlog("what section is %d?", indexPath.section);
      case kSectionCustomPlaylist:
         return YES;
      case kSectionAddableTracks:
         return NO;
   }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
   (void)tableView;

   if (sourceIndexPath.section != proposedDestinationIndexPath.section)
   {
      NSInteger row = 0;
      if (sourceIndexPath.section < proposedDestinationIndexPath.section)
         row = [self tableView:tableView numberOfRowsInSection:sourceIndexPath.section] - 1;
      return [NSIndexPath indexPathForRow:row inSection:sourceIndexPath.section];     
   }
   
   return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
   (void)tableView;
   
   switch (sourceIndexPath.section)
   {
      default:
      case kSectionAddableTracks:
         twlog("can't move row in section %d!", sourceIndexPath.section);
         break;
      case kSectionCustomPlaylist:
         twcheck(destinationIndexPath.section == sourceIndexPath.section);
         [self moveTrack:sourceIndexPath.row to:destinationIndexPath.row];
         break;
   }
}

@end

