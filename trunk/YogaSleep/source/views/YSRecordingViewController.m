//
//  YSRecordingViewController.m
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

#import "YSRecordingViewController.h"
#import "TWNavigationAppDelegate.h"
#import "YSRecordingTableViewCell.h"
#import "YSPlayerViewController.h"

@implementation YSRecordingViewController

@synthesize moreInfo;
@synthesize tracksTable;
@synthesize templateCell;
@synthesize playlist;

#pragma mark -
#pragma mark Life cycle

+ (YSRecordingViewController *)controllerForRecording:(NSInteger)idx
{
   NSDictionary *playlist = [TWDataModel().playlists objectAtIndex:idx];
   NSString *name = [playlist objectForKey:kPlaylistName];

   YSRecordingViewController *controller = [[[YSRecordingViewController alloc] initWithNibName:@"YSRecordingView" bundle:nil] autorelease];
   controller.playlist = playlist;
   controller.title = name;
   return controller;
}

- (void)viewDidLoad
{
   [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

   [[NSNotificationCenter defaultCenter] addObserver:self
      selector:@selector(trackChanged:)
      name:kTrackChangeNotification
      object:nil
    ];
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
   
	NSIndexPath *selection = [self.tracksTable indexPathForSelectedRow];
	if (selection)
		[self.tracksTable deselectRowAtIndexPath:selection animated:YES];
   
   NSString *description = [self.playlist objectForKey:kPlaylistDescription];
   self.moreInfo.text = description;
   
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

   twlog("YSRecordingViewController didReceiveMemoryWarning -- no action");
}

- (void)viewDidUnload
{
   twlog("YSRecordingViewController viewDidUnload");
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
   self.tracksTable = nil;
}

- (void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   
   twrelease(moreInfo);
   twrelease(tracksTable);
   twrelease(playlist);

   [super dealloc];
}

#pragma mark -
#pragma mark Actions

- (void)fixPlayControls
{
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
      barButtonItem = [self playingBarButtonForTarget:self action:@selector(showPlayer)];
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

- (UIBarButtonItem *)playingBarButtonForTarget:(id)target action:(SEL)action
{
	UIButton *nowPlayingButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 30)] autorelease];
	[nowPlayingButton setBackgroundImage:[UIImage imageNamed:@"button_nowplaying.png"] forState:UIControlStateNormal];
	[nowPlayingButton setBackgroundImage:[UIImage imageNamed:@"button_nowplaying-pressed.png"] forState:UIControlStateHighlighted];
	[nowPlayingButton addTarget:target action:action forControlEvents:(UIControlEventTouchUpInside)];
	UIBarButtonItem *result = [[[UIBarButtonItem alloc] initWithCustomView:nowPlayingButton] autorelease];
   return result;
}

- (void)play
{
   [TWDataModel() play:self.playlist];
   
   [self fixPlayControls];
   [self.tracksTable reloadData];
   
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
   [self.tracksTable reloadData];
}

#pragma mark -
#pragma mark Table support

- (NSDictionary *)componentAtIndex:(NSInteger)idx
{
   NSArray *components = [self.playlist objectForKey:kPlaylistComponents];
   NSString *trackID = [components objectAtIndex:idx];
   return [TWDataModel() trackWithID:trackID];
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
   
   NSInteger componentCount = [[self.playlist objectForKey:kPlaylistComponents] count];
   return componentCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   // note that identifier in nib must match
    static NSString *kRecordingViewCellIdentifier = @"RecordingCell";
    
   YSRecordingTableViewCell *cell = (YSRecordingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kRecordingViewCellIdentifier];
    if (cell == nil)
    {
       //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kRecordingViewCellIdentifier] autorelease];
       //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
       
       [[NSBundle mainBundle] loadNibNamed:@"YSTrackCell" owner:self options:nil];
       twcheck(self.templateCell);
       cell = self.templateCell;
       self.templateCell = nil;

       cell.accessoryType = UITableViewCellAccessoryNone;
    }
   /*
    if (1 & indexPath.row)
    cell.backgroundView.backgroundColor = [UIColor colorFromHexValue:0xE0E0E0];
    else
    cell.backgroundView.backgroundColor = [UIColor colorFromHexValue:0xF2F2F2];
    */
   
   [cell fillOutWithTrack:indexPath.row fromPlaylist:self.playlist];

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
   NSDictionary *component = [self componentAtIndex:indexPath.row];
   NSString *description = [component objectForKey:kTrackDescription];
   self.moreInfo.text = description;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
 	(void)tableView;
 	(void)indexPath;

   //twlog("accessory button tapped for row %i", indexPath.row);
}

@end

