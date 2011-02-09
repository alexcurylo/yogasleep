//
//  YSDataModel.m
//
//  Copyright Trollwerks Inc 2009. All rights reserved.
//

#import "YSDataModel.h"
//#import "TWXNSArray.h"
//#import "TWXNSObject.h"
//#import "TWXNSString.h"
#import "SimpleAudioEngine.h"

NSString *kTrackName = @"name";
NSString *kTrackID = @"id";
NSString *kTrackTime = @"time";
NSString *kTrackCategory = @"category";
NSString *kTrackDescription = @"description";
NSString *kTrackFile = @"file";

NSString *kPlaylistEditable = @"editable";
NSString *kPlaylistName = @"name";
NSString *kPlaylistTime = @"time";
NSString *kPlaylistCategory = @"category";
NSString *kPlaylistDescription = @"description";
NSString *kPlaylistComponents = @"components";

NSString *kTrackChangeNotification = @"TrackChange";

/*
@implementation NSString(ValueSort)

- (NSComparisonResult)compareByValue:(NSString *)otherString
{	
   //twlog("compareByNID self: %@ otherDict: %@", self, otherDict);
   NSNumber *myNID = [NSNumber numberWithFloat:[self floatValue]];
   NSNumber *otherNID = [NSNumber numberWithFloat:[otherString floatValue]];
   //twlog("myNID class: %@", [myNID className]);
   return [myNID compare:otherNID];
}

@end

@implementation NSDictionary(NIDSort)

- (NSComparisonResult)compareByNID:(NSDictionary *)otherDict
{	
   //twlog("compareByNID self: %@ otherDict: %@", self, otherDict);
   NSNumber *myNID = [NSNumber numberWithFloat:[[self objectForKey:kNutrientID] floatValue]];
   NSNumber *otherNID = [NSNumber numberWithFloat:[[otherDict objectForKey:kNutrientID] floatValue]];
   //twlog("myNID class: %@", [myNID className]);
   return [myNID compare:otherNID];
}

@end
 */

@implementation YSDataModel

@synthesize tracks;
@synthesize playlists;
@synthesize documentDirectory;
@synthesize playingPlaylist;
//@synthesize currentTrackID;
@synthesize playingIndex;

#pragma mark -
#pragma mark Life cycle

- (id)init
{
   self = [super init];
   if (self)
   {
      self.playingIndex = kNoTrackPlaying;

      // maybe we want to use CDAudioEngine interface to set pause/resume behaviour?
      [SimpleAudioEngine sharedEngine];
      [[CDAudioManager sharedManager] setMode:kAMM_MediaPlayback]; // AVAudioSessionCategoryPlayback -- Use audio exclusively, ignore mute switch and sleep
      [[CDAudioManager sharedManager] setBackgroundMusicCompletionListener:self selector:@selector(trackFinished)];
            
      NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
      self.documentDirectory = [paths objectAtIndex:0];
      
      NSString *path = [[NSBundle mainBundle] pathForResource:@"tracks" ofType:@"plist"];
      self.tracks = [NSMutableArray arrayWithContentsOfFile:path];
      twcheck(self.tracks);
 
      [self loadPlaylists];
      
      //twlog("%@", self.tracks);
      //twlog("%@", self.playlists);
   }
   
   return self;
}

- (void)dealloc
{
   twrelease(playingPlaylist);
   //twrelease(currentTrackID);

   twrelease(tracks);
   twrelease(playlists);
   twrelease(documentDirectory);

   [super dealloc];
}

#pragma mark -
#pragma mark UI stuff


#pragma mark -
#pragma mark Application support

- (UIBarButtonItem *)playingBarButtonForTarget:(id)target action:(SEL)action
{
	UIButton *nowPlayingButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 30)] autorelease];
	[nowPlayingButton setBackgroundImage:[UIImage imageNamed:@"button_nowplaying.png"] forState:UIControlStateNormal];
	[nowPlayingButton setBackgroundImage:[UIImage imageNamed:@"button_nowplaying-pressed.png"] forState:UIControlStateHighlighted];
	[nowPlayingButton addTarget:target action:action forControlEvents:(UIControlEventTouchUpInside)];
	UIBarButtonItem *result = [[[UIBarButtonItem alloc] initWithCustomView:nowPlayingButton] autorelease];
   return result;
}

- (NSString *)tracksPath
{
   NSString *tracksPath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"tracks"];
   return tracksPath;
}

- (NSString *)pathForTrack:(NSString *)track
{
   if (!track.length)
      return nil;
   
   NSString *pathForTrack = [self.tracksPath stringByAppendingPathComponent:track];
   return pathForTrack;
}

- (NSDictionary *)trackWithID:(NSString *)trackID
{
   if (!trackID.length)
      return nil;
   
   for (NSDictionary *track in self.tracks)
   {
      NSString *thisID = [track objectForKey:kTrackID];
      if ([thisID isEqual:trackID])
         return track;
   }
   
   twlog("couldn't find track id %@!", trackID);
   return nil;
}

- (NSString *)pathForTrackID:(NSString *)trackID
{
   if (!trackID.length)
      return nil;
   
   NSDictionary *track = [self trackWithID:trackID];
   NSString *trackFile = [track objectForKey:kTrackFile];
   NSString *pathForTrackID = [self pathForTrack:trackFile];
   return pathForTrackID;
}

- (NSString *)playlistsPath
{
   NSString *playlistsPath = [self.documentDirectory stringByAppendingPathComponent:@"playlists.plist"];
   return playlistsPath;
}

- (void)savePlaylists
{
   BOOL wroteOK = [self.playlists writeToFile:self.playlistsPath atomically:NO];
   twlogif(!wroteOK, "saving playlists failed!"); (void)wroteOK;
}

- (void)loadPlaylists
{
   NSString *path = self.playlistsPath;
   self.playlists = [NSMutableArray arrayWithContentsOfFile:path];
   if (!self.playlists)
   {
      twlog("loading default playlists...");
      path = [[NSBundle mainBundle] pathForResource:@"playlists" ofType:@"plist"];
      self.playlists = [NSMutableArray arrayWithContentsOfFile:path];
   }
   else
   {
      twlog("loading cached playlists...");
   }

   twcheck(self.playlists);
}

- (NSMutableDictionary *)customPlaylistNamed:(NSString *)name
{
   //NSString *name = NSLocalizedString(@"CUSTOMPLAYLIST", nil);
   NSMutableDictionary *customPlaylist = nil;
   for (NSMutableDictionary *playlist in self.playlists)
   {
      NSString *playlistName = [playlist objectForKey:kPlaylistName];
      if ([playlistName isEqual:name])
      {
         customPlaylist = playlist;
         break;
      }
   }
   
   if (!customPlaylist)
   {
      customPlaylist = [NSMutableDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithBool:YES], kPlaylistEditable,
         name, kPlaylistName,
         [NSNumber numberWithInteger:0], kPlaylistTime,
         NSLocalizedString(@"CUSTOMCATEGORY", nil), kPlaylistCategory,
         NSLocalizedString(@"CUSTOMDESCRIPTION", nil), kPlaylistDescription,
         [NSMutableArray array], kPlaylistComponents,
         nil
      ];
   }
   
   return customPlaylist;
}

- (void)setCustomPlaylist:(NSMutableDictionary *)customPlaylist
{
   BOOL playlistsChanged = NO;
   
   // remove old one if any

   //NSString *customName = NSLocalizedString(@"CUSTOMPLAYLIST", nil);
   NSString *customName = [customPlaylist objectForKey:kPlaylistName];
   NSMutableDictionary *oldCustomPlaylist = nil;
   for (NSMutableDictionary *playlist in self.playlists)
   {
      NSString *playlistName = [playlist objectForKey:kPlaylistName];
      if ([playlistName isEqual:customName])
      {
         oldCustomPlaylist = playlist;
         break;
      }
   }
   if (oldCustomPlaylist)
   {
      [[oldCustomPlaylist retain] autorelease]; // in case it's the same one
      [self.playlists removeObject:oldCustomPlaylist];
      playlistsChanged = YES;
   }
   
   // add new one if it has entries
   
   NSArray *components = [customPlaylist objectForKey:kPlaylistComponents];
   if (components.count)
   {
      [self.playlists addObject:customPlaylist];
      playlistsChanged = YES;
   }
   
   // save if changed
   
   if (playlistsChanged)
      [self savePlaylists];
}

- (BOOL)hasCustomPlaylists
{
   BOOL hasCustomPlaylists = NO;
   for (NSDictionary *playlist in self.playlists)
   {
      BOOL editable = [[playlist objectForKey:kPlaylistEditable] boolValue];
      if (editable)
      {
         hasCustomPlaylists = YES;
         break;
      }
   }
   
   return hasCustomPlaylists;
}

- (NSArray *)customPlaylists
{
   NSMutableArray *customPlaylists = [NSMutableArray array];
   for (NSDictionary *playlist in self.playlists)
   {
      BOOL editable = [[playlist objectForKey:kPlaylistEditable] boolValue];
      if (editable)
         [customPlaylists addObject:playlist];
   }
   
   return customPlaylists;
}

//- (void)removePlaylist:(NSUInteger)idx
- (void)removePlaylist:(NSDictionary *)playlist
{
   //if (idx >= self.playlists.count)
   if (!playlist)
      return;
   
   //NSDictionary *playlist = [self.playlists objectAtIndex:idx];
   if ([playlist isEqual:self.playingPlaylist])
      [self play:nil];
   
   //[self.playlists removeObjectAtIndex:idx];
   [self.playlists removeObject:playlist];
   [self savePlaylists];
}

- (BOOL)isPlayingPlaylist:(NSDictionary *)playlist
{
   if (!self.playingPlaylist || !playlist)
      return NO;
   if (playingPaused)
      return NO;
   return [playlist isEqual:self.playingPlaylist];
}

/*
- (BOOL)isCurrentTrack:(NSString *)trackID
{
   if (!self.currentTrackID || !trackID)
      return NO;
   // current track is true whether paused or not
   return [trackID isEqual:self.currentTrackID];
}
*/

- (void)togglePlayPause
{
   twcheck(self.playingPlaylist);
   // could happen from external controls, maybe
   if (!self.playingPlaylist)
      return;
   
   if (playingPaused)
      [self play:self.playingPlaylist];
   else
      [self pause:self.playingPlaylist];
}

- (void)play:(NSDictionary *)playlist
{
   if ([playlist isEqual:self.playingPlaylist] && playingPaused)
   {
      [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
      playingPaused = NO;
      return;
   }
   
   [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
   self.playingIndex = kNoTrackPlaying;
   self.playingPlaylist = playlist;
   
   if (!playlist)
      return;
   NSArray *components = [playlist objectForKey:kPlaylistComponents];
   if (!components.count)
      return;
   
   //self.currentTrackID = [components objectAtIndex:0];
   self.playingIndex = 0;
   [self startAudio];
}

- (NSDictionary *)currentTrack
{
   if (!self.playingPlaylist)
      return nil;
   if (kNoTrackPlaying >= self.playingIndex)
      return nil;
   
   NSArray *components = [self.playingPlaylist objectForKey:kPlaylistComponents];
   NSString *trackID = [components objectAtIndex:self.playingIndex];
   NSDictionary *track = [self trackWithID:trackID];
   return track;
}

- (NSInteger)trackCount
{
   if (!self.playingPlaylist)
      return 0;
   NSArray *components = [self.playingPlaylist objectForKey:kPlaylistComponents];
   return components.count;
}

- (void)startAudio
{
   //NSString *filePath = [self pathForTrackID:self.currentTrackID];
   NSArray *components = [self.playingPlaylist objectForKey:kPlaylistComponents];
   NSString *trackID = [components objectAtIndex:self.playingIndex];
   NSString *filePath = [self pathForTrackID:trackID];

   twcheck(filePath.length);
   if(filePath.length)
   {
      [[SimpleAudioEngine sharedEngine] playBackgroundMusic:filePath loop:NO];
      playingPaused = NO;
   }
}

- (void)pause:(NSDictionary *)playlist
{
   twcheck([playlist isEqual:self.playingPlaylist]);
   [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
   playingPaused = YES;
}

- (void)previousTrack
{
   // iPod app behaviour is to go to beginning after 3 seconds -- 
   // we'll assume that's handled at a higher level if so
   [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
   [self changeTrackBy:-1];
}

- (void)nextTrack
{
   [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
   [self changeTrackBy:1];
}

- (void)trackFinished
{
   [self changeTrackBy:1];
}

- (void)changeTrackBy:(NSInteger)delta
{
   twcheck(self.playingPlaylist);
   // could happen from external controls, maybe
   if (!self.playingPlaylist)
      return;

   playingPaused = NO;
   
   NSArray *components = [self.playingPlaylist objectForKey:kPlaylistComponents];
   NSInteger nextIndex = self.playingIndex + delta;
   if ((0 <= nextIndex) && (nextIndex < (NSInteger)components.count))
   {
      self.playingIndex = nextIndex;
      [self startAudio];
   }
   else
   {
      self.playingIndex = kNoTrackPlaying;
      // no, we'll let it go back to playing screen
      //self.playingPlaylist = nil;
   }
   
   [[NSNotificationCenter defaultCenter]
    postNotificationName:kTrackChangeNotification
    object:self
    userInfo:nil
    ];         
}

@end
