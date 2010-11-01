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

#pragma mark -
#pragma mark Life cycle

- (id)init
{
   self = [super init];
   if (self)
   {
      // maybe we want to use CDAudioEngine interface to set pause/resume behaviour?
      [SimpleAudioEngine sharedEngine];
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

- (NSMutableDictionary *)customPlaylist
{
   NSString *customName = NSLocalizedString(@"CUSTOMPLAYLIST", nil);
   NSMutableDictionary *customPlaylist = nil;
   for (NSMutableDictionary *playlist in self.playlists)
   {
      NSString *playlistName = [playlist objectForKey:kPlaylistName];
      if ([playlistName isEqual:customName])
      {
         customPlaylist = playlist;
         break;
      }
   }
   
   if (!customPlaylist)
   {
      customPlaylist = [NSMutableDictionary dictionaryWithObjectsAndKeys:
         customName, kPlaylistName,
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

   NSString *customName = NSLocalizedString(@"CUSTOMPLAYLIST", nil);
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

- (void)play:(NSDictionary *)playlist
{
   if ([playlist isEqual:self.playingPlaylist])
   {
      twcheck(playingPaused);
      [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
      playingPaused = NO;
      return;
   }
   
   //self.currentTrackID = nil;
   playingIndex = -1;
   [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
   
   NSArray *components = [playlist objectForKey:kPlaylistComponents];
   if (!components.count)
      return;
   
   self.playingPlaylist = playlist;
   //self.currentTrackID = [components objectAtIndex:0];
   playingIndex = 0;
   [self startAudio];
}

- (void)startAudio
{
   //NSString *filePath = [self pathForTrackID:self.currentTrackID];
   NSArray *components = [self.playingPlaylist objectForKey:kPlaylistComponents];
   NSString *trackID = [components objectAtIndex:playingIndex];
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

- (void)trackFinished
{
   twcheck(!playingPaused);
   //twcheck(self.currentTrackID);
   twcheck(self.playingPlaylist);

   playingPaused = NO;
   
   NSArray *components = [self.playingPlaylist objectForKey:kPlaylistComponents];
   /*
   NSString *nextTrackID = nil;
   BOOL foundThisTrack = NO;
   for (NSString *component in components)
   {
      if (foundThisTrack)
      {
         nextTrackID = component;
         break;
      }
      if ([component isEqual:self.currentTrackID])
         foundThisTrack = YES;
   }
   
   if (nextTrackID.length)
   {
      self.currentTrackID = nextTrackID;
      [self startAudio];
   }
   else
   {
      self.currentTrackID = nil;
      self.playingPlaylist = nil;
   }
    */
   NSInteger nextIndex = playingIndex + 1;
   if (nextIndex < (NSInteger)components.count)
   {
      playingIndex = nextIndex;
      [self startAudio];
   }
   else
   {
      playingIndex = -1;
      self.playingPlaylist = nil;
   }
   
   [[NSNotificationCenter defaultCenter]
    postNotificationName:kTrackChangeNotification
    object:self
    userInfo:nil
    ];         
}

@end
