//
//  YSPlayerViewController.m
//
//  Copyright 2011 Trollwerks Inc. All rights reserved.
//

#import "YSPlayerViewController.h"
#import "TWNavigationAppDelegate.h"
#import "TWSecondsFormatter.h"
#import "CDAudioManager.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation YSPlayerViewController

@synthesize albumArtworkImageView;
@synthesize playbackTopOverlayView;
@synthesize playlistPositionLabel;
@synthesize timeElapsedLabel;
@synthesize timeRemainingLabel;
@synthesize playbackPositionSlider;
@synthesize playbackBottomOverlayView;
@synthesize previousSongButton;
@synthesize playButton;
@synthesize pauseButton;
@synthesize nextSongButton;
@synthesize volumePlaceHolder;
/*
@synthesize titleView;
@synthesize titleArtistLabel;
@synthesize titleSongLabel;
@synthesize titleAlbumLabel;
*/
@synthesize secondsFormatter;
@synthesize updateTimer;

+ (YSPlayerViewController *)controller
{
	YSPlayerViewController *controller = [[[YSPlayerViewController alloc] initWithNibName:@"YSPlayerView" bundle:nil] autorelease];
   controller.title = NSLocalizedString(@"TITLEPLAYER", nil);

   // this apparently must be done before the view is loaded
   //controller.hidesBottomBarWhenPushed = YES;

   return controller;
}

#pragma mark -

- (void)viewDidLoad
{
   [super viewDidLoad];

	self.playlistPositionLabel.font = [UIFont boldSystemFontOfSize:11.0];
   self.timeElapsedLabel.font = [UIFont boldSystemFontOfSize:13.0];
	self.timeRemainingLabel.font = [UIFont boldSystemFontOfSize:13.0];
   
   /*
	self.titleArtistLabel.font = [UIFont boldSystemFontOfSize:12.0];
   self.titleArtistLabel.textColor = [UIColor lightGrayColor]; 
	self.titleSongLabel.font = [UIFont boldSystemFontOfSize:12.0];
   self.titleSongLabel.textColor = [UIColor whiteColor]; 
	self.titleAlbumLabel.font = [UIFont boldSystemFontOfSize:12.0];
   self.titleAlbumLabel.textColor = [UIColor lightGrayColor]; 
   self.navigationItem.titleView = self.titleView;
    */
   /*
   UIButton *customBackButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 30)] autorelease];
	[customBackButton setBackgroundImage:[UIImage imageNamed:@"navigation_back.png"] forState:UIControlStateNormal];
	[customBackButton addTarget:self action:@selector(navigateBack) forControlEvents:(UIControlEventTouchUpInside)];
	UIBarButtonItem *customBackButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:customBackButton] autorelease];
   self.navigationItem.leftBarButtonItem = customBackButtonItem;
    */
   /*
   UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[infoButton addTarget:self action:@selector(showInfo) forControlEvents:(UIControlEventTouchUpInside)];
	UIBarButtonItem *infoButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:infoButton] autorelease];
   self.navigationItem.rightBarButtonItem = infoButtonItem;
    */
   
	CGRect frame = self.volumePlaceHolder.frame;
	MPVolumeView *volumeView = [[[MPVolumeView alloc] initWithFrame:frame] autorelease];
	[self.playbackBottomOverlayView addSubview:volumeView];
 	[self.volumePlaceHolder removeFromSuperview];
  
   self.secondsFormatter = [[[TWSecondsFormatter alloc] init] autorelease];

	//_filePlayer = [CMPEFileAQPlayer sharedPlayer];
   
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songChanged:) name:kTrackChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];

   //twcheck(appDelegate.currentSong);
   [self updateSongView];

   //self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
   //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];

   self.updateTimer = [NSTimer
      scheduledTimerWithTimeInterval:.1
      target:self
      selector:@selector(timerFireMethod:)
      userInfo:nil
      repeats:YES
   ];
}

- (void)viewWillDisappear:(BOOL)animated
{
   [super viewWillDisappear:animated];

   //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
   //self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
   
   [self.updateTimer invalidate];
   self.updateTimer = nil;
}

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];

   twlog("YSPlayerViewController didReceiveMemoryWarning -- no action");
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
	self.albumArtworkImageView = nil;
	self.playbackTopOverlayView = nil;
	self.playlistPositionLabel = nil;
	self.timeElapsedLabel = nil;
	self.timeRemainingLabel = nil;
	self.playbackPositionSlider = nil;
	self.playbackBottomOverlayView = nil;
	self.previousSongButton = nil;
	self.playButton = nil;
	self.pauseButton = nil;
	self.nextSongButton = nil;
	self.volumePlaceHolder = nil;
/*
 self.titleView = nil;
	self.titleArtistLabel = nil;
	self.titleSongLabel = nil;
*/
}

- (void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   
   [updateTimer invalidate];
	twrelease(updateTimer);

	twrelease(albumArtworkImageView);
	twrelease(playbackTopOverlayView);
	twrelease(playlistPositionLabel);
	twrelease(timeElapsedLabel);
	twrelease(timeRemainingLabel);
	twrelease(playbackPositionSlider);
	twrelease(playbackBottomOverlayView);
	twrelease(previousSongButton);
	twrelease(playButton);
	twrelease(pauseButton);
	twrelease(nextSongButton);
	twrelease(volumePlaceHolder);
/*
 twrelease(titleView);
	twrelease(titleArtistLabel);
	twrelease(titleSongLabel);
*/
	twrelease(secondsFormatter);

   [super dealloc];
}

#pragma mark -

- (void)timerFireMethod:(NSTimer*)theTimer
{
	(void)theTimer;
   
   if (![playbackPositionSlider isTracking])
      [self updateSongPosition];
}

- (void)songChanged:(NSNotification*)notification
{
   (void)notification;
   
   /* check play finished, for
    // we'd hope this got caught in updateSongPosition, but just in case
    self.playbackPositionSlider.value = 0;
    self.pauseButton.hidden = YES;
    self.playButton.hidden = NO;
    */
   
   /* no, we'll let them restart or whatever
    if (!TWDataModel().currentTrack)
      [self navigateBack];
   else
   */
   [self updateSongView];
}

- (void)updateSongView
{
   /*
   NSDictionary *currentTrack = TWDataModel().currentTrack;
   
   self.titleArtistLabel.text = appDelegate.currentSong.artist;
   self.titleSongLabel.text = appDelegate.currentSong.title;
	self.titleAlbumLabel.text = appDelegate.currentSong.album;
   */
   //if (!self.titleAlbumLabel.text.length)
      //self.titleAlbumLabel.text = @"No Album";

   /*
	UIImage *artwork = [appDelegate.currentSong loadArtwork];
   if (!artwork && appDelegate.currentSong.isBundled)
   {
      // see if we can find album art then
      PMPESong *bundle = [appDelegate  bundleWithID:appDelegate.currentSong.bundledID];
      if (bundle)
         artwork = [bundle loadArtwork];
   }
   if (!artwork)
      artwork = [UIImage imageNamed:@"Default.png"];
   self.albumArtworkImageView.image = artwork;
   */
   
   [self updateSongPosition];
   
   /*
	if ([appDelegate.playlist containsObject:appDelegate.currentSong])
	{
		NSUInteger playlistPosition = [appDelegate.playlist indexOfObject:appDelegate.currentSong];
		self.playlistPositionLabel.text = [NSString stringWithFormat:@"%u of %u", playlistPosition + 1, appDelegate.playlist.count];		
	}
	else
   {
		//self.playlistPositionLabel.text = @"Playing Library";
		NSUInteger libraryPosition = [appDelegate libraryIndexOf:appDelegate.currentSong];
		self.playlistPositionLabel.text = [NSString stringWithFormat:@"%u of %u", libraryPosition + 1, appDelegate.libraryCount];		
   }
    */
   self.playlistPositionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"PLAYINDEX", nil),
      TWDataModel().playingIndex + 1,
      TWDataModel().trackCount
   ];
}

- (void)updateSongPosition
{
   //twlog("implement updateSongPosition!");
   /*
   if (_filePlayer.isSeeking)
      return;
    */
   //AVAudioPlayer *audioSourcePlayer = [SimpleAudioEngine sharedEngine]
   AVAudioPlayer *audioSourcePlayer = [CDAudioManager sharedManager].backgroundMusic.audioSourcePlayer;
   
   if (audioSourcePlayer)
   {
      NSTimeInterval position = audioSourcePlayer.currentTime;
      NSTimeInterval endSeconds = audioSourcePlayer.duration;
      self.playbackPositionSlider.value = position / endSeconds;
      
      float nowSeconds = position; // * endSeconds;
      self.timeElapsedLabel.text = [secondsFormatter stringForObjectValue:[NSNumber numberWithFloat:nowSeconds]];
      self.timeRemainingLabel.text = [secondsFormatter stringForObjectValue:[NSNumber numberWithFloat:-1 * (endSeconds - nowSeconds)]];

      self.pauseButton.hidden = !audioSourcePlayer.isPlaying;
      self.playButton.hidden = audioSourcePlayer.isPlaying;
   }
   else
   {
      self.playbackPositionSlider.value = 0;
      self.timeElapsedLabel.text = @"0:00";
      self.timeRemainingLabel.text = @"-0:00";
      
      self.pauseButton.hidden = YES;
      self.playButton.hidden = NO;
   }
}

- (IBAction)previousSong:(id)sender
{
	(void)sender;
   
   [TWDataModel() previousTrack];
   [self updateSongView];

   /*
   // emulate iPod app behaviour: after first 2 seconds goes to beginning of currentSong
   float endSeconds = [_filePlayer trackSeconds];
   float nowSeconds = self.playbackPositionSlider.value * endSeconds;
   if (3 < nowSeconds)
   {
      //self.playbackPositionSlider.value = 0;
		//[_filePlayer seek:0];
      [_filePlayer performSelector:@selector(seek:)
         onThread:_filePlayer.playerThread 
         withObject:[NSNumber numberWithFloat:0] 
         waitUntilDone:YES
      ];
      return;
   }
   
	NSUInteger songIndex = [appDelegate.playlist indexOfObject:appDelegate.currentSong];
	
	if( [appDelegate.playlist containsObject:appDelegate.currentSong] )
	{	
		if(songIndex == 0)
		{
         // like what iPod app does
			[_filePlayer stop];
         [appDelegate setCurrentSong:nil];
         //[self navigateBack];
		}
		else
		{
			songIndex--;
			PMPESong *previousSong = [appDelegate.playlist objectAtIndex:songIndex];
         [appDelegate playSong:previousSong];
			[self updateSongView];
		}
   }
   else
   {
      songIndex = [appDelegate libraryIndexOf:appDelegate.currentSong];
		if(songIndex == 0)
      {
         // like what iPod app does
         [_filePlayer stop];
         [appDelegate setCurrentSong:nil];
         //[self navigateBack];
      }
      else
      {
         PMPESong *previousLibrarySong = [appDelegate songAtIndex:songIndex - 1];
         [appDelegate playSong:previousLibrarySong];
			[self updateSongView];
     }
   }
    */
}

- (IBAction)nextSong:(id)sender
{
	(void)sender;
   
   [TWDataModel() nextTrack];
   [self updateSongView];
   
   /*
	NSUInteger songIndex = 0;
	
	if( [appDelegate.playlist containsObject:appDelegate.currentSong] )
	{	
		songIndex = [appDelegate.playlist indexOfObject:appDelegate.currentSong] + 1;
		
		if(songIndex > (appDelegate.playlist.count - 1))
		{
         // like what iPod app does
			[_filePlayer stop];
         [appDelegate setCurrentSong:nil];
         //[self navigateBack];
			return;
		}
		else
		{
			PMPESong *nextSong = [appDelegate.playlist objectAtIndex:songIndex];
         [appDelegate playSong:nextSong];
			[self updateSongView];
		}
	}
   else
   {
      songIndex = [appDelegate libraryIndexOf:appDelegate.currentSong] + 1;
		if(songIndex > ([appDelegate libraryCount] - 1))
      {
         // like what iPod app does
         [_filePlayer stop];
         [appDelegate setCurrentSong:nil];
         //[self navigateBack];
      }
      else
      {
         PMPESong *nextLibrarySong = [appDelegate songAtIndex:songIndex];
         [appDelegate playSong:nextLibrarySong];
			[self updateSongView];
      }
   }
    */
}

- (IBAction)playSong:(id)sender
{
	(void)sender;
   
   
   [TWDataModel() play:TWDataModel().playingPlaylist];
   [self updateSongPosition];
}

- (IBAction)pauseSong:(id)sender
{
	(void)sender;
   
   [TWDataModel() pause:TWDataModel().playingPlaylist];
   [self updateSongPosition];
}

- (IBAction)playbackPositionSlid:(id)sender
{	
   AVAudioPlayer *audioSourcePlayer = [CDAudioManager sharedManager].backgroundMusic.audioSourcePlayer;
   if (!audioSourcePlayer)
      return;
 
   UISlider* slider = (UISlider *)sender;
   NSTimeInterval newTime = audioSourcePlayer.duration * slider.value;
   [audioSourcePlayer setCurrentTime:newTime];
}

- (void)showInfo
{
   twlog("implement showInfo!");
   /*
    // check to see if we got here from info, if so just go to that one with our info
   // otherwise, there's no bound on how deep a stack we could get into!
   for (PMPEDetailViewController *controller in  self.navigationController.viewControllers)
      if ([controller isKindOfClass:[PMPEDetailViewController class]])
      {
         controller.title = appDelegate.currentSong.title;
         controller.songDetail = [appDelegate.currentSong loadHTMLRepresentation];
         [controller showDetails];
         [self.navigationController popToViewController:controller animated:YES];
         return;
      }
   
   // nope; so populate and show a new info view that can only go back
	PMPEDetailViewController *detailViewController = [[PMPEDetailViewController alloc] initWithNibName:@"PMPEDetailView" bundle:nil];
	detailViewController.title = appDelegate.currentSong.title;
	detailViewController.createdByPlayer = YES;
	detailViewController.songDetail = [appDelegate.currentSong loadHTMLRepresentation];
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
    */
}

- (void)navigateBack
{
   [self.navigationController popViewControllerAnimated:YES];
}

@end
