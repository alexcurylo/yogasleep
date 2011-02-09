//
//  YSAddViewController.m
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

#import "YSAddViewController.h"
#import "TWNavigationAppDelegate.h"
#import "YSRecordingTableViewCell.h"
#import "YSPlayerViewController.h"

@implementation YSAddViewController

@synthesize moreInfo;
@synthesize createTable;
@synthesize templateCell;
@synthesize playlistName;
@synthesize playlist;
@synthesize categoryNames;
@synthesize categoryTracks;

#pragma mark -
#pragma mark Life cycle

+ (YSAddViewController *)controllerWithName:(NSString *)name
{
   YSAddViewController *controller = [[[YSAddViewController alloc] initWithNibName:@"YSAddView" bundle:nil] autorelease];
   controller.title = NSLocalizedString(@"TITLEADD", nil);
   //controller.title = name;
   controller.playlistName = name;
   return controller;
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   self.categoryNames = [NSArray arrayWithObjects:
      NSLocalizedString(@"CATEGORYA", nil),
      NSLocalizedString(@"CATEGORYB", nil),
      NSLocalizedString(@"CATEGORYC", nil),
      NSLocalizedString(@"CATEGORYD", nil),
      NSLocalizedString(@"CATEGORYE", nil),
      NSLocalizedString(@"CATEGORYF", nil),
      nil
   ];
   self.categoryTracks = [NSMutableArray arrayWithObjects:
      [NSMutableArray array],
      [NSMutableArray array],
      [NSMutableArray array],
      [NSMutableArray array],
      [NSMutableArray array],
      [NSMutableArray array],
      nil
   ];
   for (NSDictionary *track in TWDataModel().tracks)
   {
      NSString *trackID = [track objectForKey:kTrackID];
      NSInteger categoryIdx = 0;
      switch ([trackID characterAtIndex:0])
      {
         default:
            twlog("unexpected trackID %@!", trackID);
         case 'A': categoryIdx = 0; break;
         case 'B': categoryIdx = 1; break;
         case 'C': categoryIdx = 2; break;
         case 'D': categoryIdx = 3; break;
         case 'E': categoryIdx = 4; break;
         case 'F': categoryIdx = 5; break;
      }
      NSMutableArray *category = [self.categoryTracks objectAtIndex:categoryIdx];
      [category addObject:track];
   }
   
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
   
   self.playlist = [TWDataModel() customPlaylistNamed:self.playlistName];
   [self.createTable reloadData];

   //NSString *description = [self.playlist objectForKey:kPlaylistDescription];
   //self.moreInfo.text = description;
   self.moreInfo.text = NSLocalizedString(@"INFOADD", nil);
 
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

   twlog("YSAddViewController didReceiveMemoryWarning -- no action");
}

- (void)viewDidUnload
{
   twlog("YSAddViewController viewDidUnload");
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
   twrelease(playlistName);
   twrelease(playlist);
   twrelease(categoryNames);
   twrelease(categoryTracks);

   [super dealloc];
}

#pragma mark -
#pragma mark Actions


- (void)fixPlayControls
{
   /*
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
    */
   UIBarButtonItem *barButtonItem = nil;
   
   BOOL playing = [TWDataModel() isPlayingPlaylist:self.playlist];
   if (playing)
   {
      /*
       NSString *imageName = nil;
       SEL action = nil;
       imageName = @"Pause 32x32.png";
       action = @selector(pause);
       barButtonItem = [[[UIBarButtonItem alloc]
       initWithImage:[UIImage imageNamed:imageName]
       style:UIBarButtonItemStyleBordered
       target:self
       action:action
       ] autorelease];
       */
      barButtonItem = [TWDataModel() playingBarButtonForTarget:self action:@selector(showPlayer)];
   }
   else
   {
      //NSString *imageName = @"Play 32x32.png"; 
      SEL action = @selector(play);
      barButtonItem = [[[UIBarButtonItem alloc]
                        //initWithImage:[UIImage imageNamed:imageName]
                        //style:UIBarButtonItemStyleBordered
                        initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                        target:self
                        action:action
                        ] autorelease];
   }
   
   self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (void)play
{
   [TWDataModel() play:self.playlist];
   
   [self fixPlayControls];
   [self.createTable reloadData];
   
   [self showPlayer];
}

- (void)pause
{
   [TWDataModel() pause:self.playlist];
   
   [self fixPlayControls];
}

- (void)showPlayer
{
	YSPlayerViewController *controller = [YSPlayerViewController controller];
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)trackChanged:(NSNotification *)note
{
   (void)note;
	
   [self fixPlayControls];
   [self.createTable reloadData];
}

- (void)addTrack:(NSIndexPath *)indexPath
{
   //NSDictionary *track = [TWDataModel().tracks objectAtIndex:indexPath.row];
   NSDictionary *track = [[self.categoryTracks objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

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
    return kAddSectionsCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	(void)tableView;
	
   NSString *sectionTitle = nil;
   switch (section)
   {
      default:
         twlog("what section is %d?", section);
         section = 0;
         // FALL
      case kAddSectionCategoryA:
      case kAddSectionCategoryB:
      case kAddSectionCategoryC:
      case kAddSectionCategoryD:
      case kAddSectionCategoryE:
      case kAddSectionCategoryF:
         sectionTitle = [self.categoryNames objectAtIndex:section];
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
         rows = 0;
         break;
      case kAddSectionCategoryA:
      case kAddSectionCategoryB:
      case kAddSectionCategoryC:
      case kAddSectionCategoryD:
      case kAddSectionCategoryE:
      case kAddSectionCategoryF:
         rows = [[self.categoryTracks objectAtIndex:section] count];
         break;
   }
   
   return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   (void)tableView;
   
   CGFloat rowHeight = kStandardCellHeight;
   
   //NSDictionary *track = [TWDataModel().tracks objectAtIndex:indexPath.row];
   NSDictionary *track = [[self.categoryTracks objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
   NSString *name = [track objectForKey:kTrackName];
   UIFont *nameFont = [UIFont boldSystemFontOfSize:kCellNameSize];
   NSInteger numberOfLines = ceilf([name sizeWithFont:nameFont constrainedToSize:CGSizeMake(kCellNameEditingWidth, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap].height/20.0);
   if (2 < numberOfLines)
      rowHeight += (numberOfLines - 2) * kExtraLineHeight;
   
   return rowHeight;
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
         break;
      case kAddSectionCategoryA:
      case kAddSectionCategoryB:
      case kAddSectionCategoryC:
      case kAddSectionCategoryD:
      case kAddSectionCategoryE:
      case kAddSectionCategoryF:
         {
         //[cell fillOutWithDataModelTrack:indexPath.row];
         NSDictionary *track = [[self.categoryTracks objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
         [cell fillOutWithTrackDictionary:track];
            
         NSMutableArray *components = [self.playlist objectForKey:kPlaylistComponents];
         NSString *trackID = [track objectForKey:kTrackID];
         NSUInteger idx = [components indexOfObject:trackID];
         if (NSNotFound != idx)
            // color of add control
            [cell setStringsColor:[UIColor colorWithRed:0.162 green:0.611 blue:0.147 alpha:1.000]];
         else
            [cell setStringsColor:[UIColor blackColor]];
         }
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
   
   //twlog("selected row %i", indexPath.row);
   NSDictionary *track = nil;
   switch (indexPath.section)
   {
      default:
         twlog("unexpected section selected!");
         return;
      case kAddSectionCategoryA:
      case kAddSectionCategoryB:
      case kAddSectionCategoryC:
      case kAddSectionCategoryD:
      case kAddSectionCategoryE:
      case kAddSectionCategoryF:
         //track = [TWDataModel().tracks objectAtIndex:indexPath.row];
         track = [[self.categoryTracks objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
         break;
   }
   
   NSString *description = [track objectForKey:kTrackDescription];
   self.moreInfo.text = description.length ? description : NSLocalizedString(@"INFOADD", nil);
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
         return UITableViewCellEditingStyleNone;
      case kAddSectionCategoryA:
      case kAddSectionCategoryB:
      case kAddSectionCategoryC:
      case kAddSectionCategoryD:
      case kAddSectionCategoryE:
      case kAddSectionCategoryF:
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
         break;
      case kAddSectionCategoryA:
      case kAddSectionCategoryB:
      case kAddSectionCategoryC:
      case kAddSectionCategoryD:
      case kAddSectionCategoryE:
      case kAddSectionCategoryF:
         [self addTrack:indexPath];
         break;
   }
}

/*
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
   (void)tableView;
   
   switch (indexPath.section)
   {
      default:
         twlog("what section is %d?", indexPath.section);
      case kSectionAddableTracks:
         return NO;
   }
}
*/
/*
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
*/
/*
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
   (void)tableView;
   (void)destinationIndexPath;

   switch (sourceIndexPath.section)
   {
      default:
      case kSectionAddableTracks:
         twlog("can't move row in section %d!", sourceIndexPath.section);
         break;
   }
}
*/

@end

