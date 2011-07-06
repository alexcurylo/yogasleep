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
#import "ASIHTTPRequest.h"
#import "TWXUIAlertView.h"
#import "TWXNSString.h"
#import "TWNavigationAppDelegate.h"

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

NSString *kDropboxBaseLink = @"http://dl.dropbox.com/u/11015966/yogasleep/";
NSString *kLocalBasePath = @"yogasleep";
NSString *kLocalDownloadsPath = @"downloads";
NSString *kTracksSubfolder = @"tracks";
NSString *kManifestPlist = @"manifest.plist";
NSString *kManifestFile = @"file";
NSString *kManifestVersion = @"version";
NSString *kTracksPlist = @"tracks.plist";
NSString *kPlaylistsPlist = @"playlists.plist";
NSString *kPlaylistsLitePlist = @"playlists-lite.plist";

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
@synthesize basePlaylists;
@synthesize customPlaylists;
@synthesize combinedPlaylists;
@synthesize installedManifest;
@synthesize latestManifest;
@synthesize documentDirectory;
@synthesize downloadsDirectory;
@synthesize playingPlaylist;
@synthesize playingIndex;
@synthesize downloadQueue;

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
      
      NSFileManager *fileManager = [NSFileManager defaultManager];
      NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
      self.documentDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:kLocalBasePath];
      if (![fileManager fileExistsAtPath:self.documentDirectory])
      {
         NSString *docsAndTracks = [self.documentDirectory stringByAppendingPathComponent:kTracksSubfolder];
			[fileManager createDirectoryAtPath:docsAndTracks withIntermediateDirectories:YES attributes:nil error:nil];
      }
      self.downloadsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:kLocalDownloadsPath];
      if (![fileManager fileExistsAtPath:self.downloadsDirectory])
      {
         NSString *downsAndTracks = [self.downloadsDirectory stringByAppendingPathComponent:kTracksSubfolder];
			[fileManager createDirectoryAtPath:downsAndTracks withIntermediateDirectories:YES attributes:nil error:nil];
      }
      
      [self loadManifest];

      [self loadTracks];
 
      [self loadPlaylists];
            
      //twlog("%@", self.tracks);
      //twlog("%@", self.playlists);

      [self initDownloadQueue];
   }
   
   return self;
}

- (void)initDownloadQueue
{
   //self.downloadQueue = [[[NSOperationQueue alloc] init] autorelease];
   self.downloadQueue = [ASINetworkQueue queue];
   // setShouldCancelAllRequestsOnFailure:YES
   // setMaxConcurrentOperationCount:4
   [self.downloadQueue setMaxConcurrentOperationCount:4];
   //[self.downloadQueue setDelegate:self];
   //[self.downloadQueue setRequestDidFinishSelector:@selector(poseRequestFinished:)];
   //[self.downloadQueue setRequestDidFailSelector:@selector(poseRequestFailed:)];
   //[self.downloadQueue setQueueDidFinishSelector:@selector(poseQueueFinished:)];
   [self.downloadQueue go]; // we won't use its progress functionality
}

- (void)cleanDownloadQueue
{
   [self.downloadQueue setDelegate:nil];
   [self.downloadQueue reset];
}

- (void)dealloc
{
   [self cleanDownloadQueue];
   twrelease(downloadQueue);

   twrelease(playingPlaylist);
   //twrelease(currentTrackID);

   twrelease(tracks);
   twrelease(basePlaylists);
   twrelease(customPlaylists);
   twrelease(combinedPlaylists);
   twrelease(installedManifest);
   twrelease(latestManifest);
   twrelease(documentDirectory);
   twrelease(downloadsDirectory);

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

- (NSString *)pathForUpdatableFile:(NSString *)file
{
   NSString *path = nil;
   
   path = [self.documentDirectory stringByAppendingPathComponent:file];
   BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path];
   if (exists)
   {
      twlog("updatable file %@ in document directory", file);
      return path;
   }
   
   //NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"moreinfo" ofType:@"html"];
   path = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:file];
   exists = [[NSFileManager defaultManager] fileExistsAtPath:path];
   if (exists)
   {
      twlog("updatable file %@ in main bundle", file);
      return path;
   }
   
   twlog("updatable file %@ NOT FOUND!!", file);
   return nil;
}

- (void)loadManifest
{
   /*
   NSString *path = [self pathForUpdatableFile:kManifestPlist];
   self.installedManifest = [NSMutableArray arrayWithContentsOfFile:path];
   twcheck(self.installedManifest);
   self.latestManifest = [self.installedManifest mutableCopy];
    */
   NSString *installedPath = [self pathForUpdatableFile:kManifestPlist];
   NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:kManifestPlist];
   if ([installedPath isEqualToString:bundlePath])
   {
      self.installedManifest = [NSMutableArray arrayWithContentsOfFile:installedPath];
      twcheck(self.installedManifest);
   }
   else
   {
      // check to see if bundle is later than installed
      
      self.installedManifest = [NSMutableArray arrayWithContentsOfFile:installedPath];
      NSInteger installedVersion = 0;
      for (NSDictionary *installedEntry in self.installedManifest)
         if ([kTracksPlist isEqual:[installedEntry objectForKey:kManifestFile]])
            installedVersion = [[installedEntry objectForKey:kManifestVersion] integerValue];
      
      NSMutableArray *bundleManifest = [NSMutableArray arrayWithContentsOfFile:bundlePath];
      NSInteger bundleVersion = 0;
      for (NSDictionary *bundleEntry in bundleManifest)
         if ([kTracksPlist isEqual:[bundleEntry objectForKey:kManifestFile]])
            bundleVersion = [[bundleEntry objectForKey:kManifestVersion] integerValue];
      
      if (installedVersion < bundleVersion)
      {
         twlog("later bundled version of tracks.plist -- removing downloaded files!");
         self.installedManifest = bundleManifest;
         
         NSError *error = nil;
         BOOL removed = [[NSFileManager defaultManager] removeItemAtPath:installedPath error:&error];
         twcheck(removed && !error);
         installedPath = [self.documentDirectory stringByAppendingPathComponent:kTracksPlist];
         removed = [[NSFileManager defaultManager] removeItemAtPath:installedPath error:&error];
         twcheck(removed && !error);
         installedPath = [self.documentDirectory stringByAppendingPathComponent:kPlaylistsPlist];
         removed = [[NSFileManager defaultManager] removeItemAtPath:installedPath error:&error];
         twcheck(removed && !error);
         installedPath = [self.documentDirectory stringByAppendingPathComponent:kPlaylistsLitePlist];
         removed = [[NSFileManager defaultManager] removeItemAtPath:installedPath error:&error];
         twcheck(removed && !error);

         installedPath = [self.documentDirectory stringByAppendingPathComponent:@"introduction.html"];
         removed = [[NSFileManager defaultManager] removeItemAtPath:installedPath error:&error];
         twcheck(removed && !error);
         installedPath = [self.documentDirectory stringByAppendingPathComponent:@"introduction-lite.html"];
         removed = [[NSFileManager defaultManager] removeItemAtPath:installedPath error:&error];
         twcheck(removed && !error);
         installedPath = [self.documentDirectory stringByAppendingPathComponent:@"moreinfo.html"];
         removed = [[NSFileManager defaultManager] removeItemAtPath:installedPath error:&error];
         twcheck(removed && !error);
      }
   }
   
   self.latestManifest = [self.installedManifest mutableCopy];
}

- (void)loadTracks
{
   //NSString *path = [[NSBundle mainBundle] pathForResource:@"tracks" ofType:@"plist"];
   NSString *path = [self pathForUpdatableFile:kTracksPlist];
   self.tracks = [NSMutableArray arrayWithContentsOfFile:path];
   twcheck(self.tracks);
}

- (void)loadPlaylists
{
#if YOGASLEEPFULL
   NSString *basePlaylistsPath = [self pathForUpdatableFile:kPlaylistsPlist];
#elif YOGASLEEPLITE
   NSString *basePlaylistsPath = [self pathForUpdatableFile:kPlaylistsLitePlist];
#else
#error version not set!
#endif //YOGASLEEPFULL
   self.basePlaylists = [NSArray arrayWithContentsOfFile:basePlaylistsPath];
   twcheck(self.basePlaylists.count);
   
   self.customPlaylists = [NSMutableArray arrayWithContentsOfFile:self.customPlaylistsPath];
   if (!self.customPlaylists)
      self.customPlaylists = [NSMutableArray array];
   twlog("%d custom playlists found", self.customPlaylists.count);
   
   [self combinePlaylists];
}

- (void)combinePlaylists
{
   self.combinedPlaylists = [self.basePlaylists mutableCopy];
   [self.combinedPlaylists addObjectsFromArray:self.customPlaylists];
}

- (void)checkForDownloadableTracks
{
   if (self.downloadQueue.operations.count)
      return;
   
   for (NSDictionary *entry in self.tracks)
   {
      NSString *file = [entry objectForKey:kTrackFile];
      NSString *path = [self pathForTrack:file];
      if (path.length)
      {
         twlog("checkForDownloadableTracks: file %@ is present", file);
         continue;
      }
 
#if YOGASLEEPLITE
      if (![self isDownloadableTrack:file])
      {
         twlog("checkForDownloadableTracks: %@ not downloadable", file);
         continue;
      }
#endif //YOGASLEEPLITE

      file = [@"tracks/" stringByAppendingString:file];
      NSDictionary *manifestEntry = [self latestEntry:file];
      if (!manifestEntry)
      {
         twlog("checkForDownloadableTracks: %@ has no manifest entry?", file);
         continue;
      }
      NSString *fileLink = [kDropboxBaseLink stringByAppendingString:file];
      twlog("checkForDownloadableTracks: downloading %@: %@", file, fileLink);
      ASIHTTPRequest *fileRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:fileLink]];
      fileRequest.userInfo = [manifestEntry copy];
      NSString *downloadPath = [self.downloadsDirectory stringByAppendingPathComponent:file];
      [fileRequest setDownloadDestinationPath:downloadPath];
      [fileRequest setDelegate:self];
      fileRequest.didFinishSelector = @selector(fileRequestFinished:);
      fileRequest.didFailSelector = @selector(fileRequestFailed:);
      [self.downloadQueue addOperation:fileRequest];
   }
}

- (void)updateManifest
{
//#warning simulating network fail
   //return;
   
   //if (manifestUpdating)
   if (self.downloadQueue.operations.count)
   {
      twlog("updateManifest: self.downloadQueue.operations.count exists, ignoring...");
      return;
   }
   
   //manifestUpdating = YES;   
   // note that stringByAppendingPathComponent will change // after http:// to single slash, 
   // giving the uninformative "ASIHTTPRequestErrorDomain Code=6 "Unable to start HTTP connection"" error
   NSString *manifestLink = [kDropboxBaseLink stringByAppendingString:kManifestPlist];

   
#if REQUEST_MANIFEST_NSURLCONNECTION
   if ([TWURLFetcher activeFetchersCount])
   {
      twlog("%d active fetchers, not updating manifest", [TWURLFetcher activeFetchersCount]);
      return;
   }
   
   twlog("fetching manifest with TWURLFetcher: %@", manifestLink);
   TWURLFetcher *manifestFetcher = [TWURLFetcher urlFetcher:manifestLink target:self selector:@selector(fetchedManifest:)];
   twcheck(manifestFetcher); (void)manifestFetcher;
#else
   twlog("fetching manifest with ASIHTTPRequest: %@", manifestLink);
   ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:manifestLink]];
   [request setDelegate:self];
   request.didFinishSelector = @selector(manifestRequestFinished:);
   request.didFailSelector = @selector(manifestRequestFailed:);
   [self.downloadQueue addOperation:request];
   //[request startAsynchronous];
#endif //REQUEST_MANIFEST_NSURLCONNECTION
}

#if REQUEST_MANIFEST_NSURLCONNECTION
- (void)fetchedManifest:(TWURLFetcher *)fetcher
{
   if (!fetcher.succeeded)
   {
      twlog("fetchedManifest FAIL!");
      return;
   }
   
   NSData *fileData = fetcher.connectionData;
   [self parseManifestData:fileData];
}
#else
- (void)manifestRequestFinished:(ASIHTTPRequest *)request
{
   NSData *fileData = request.responseData;
   [self parseManifestData:fileData;
}
#endif //REQUEST_MANIFEST_NSURLCONNECTION

- (void)parseManifestData:(NSData *)fileData
{
   if (!fileData.length)
   {
      twlog("parseManifestData -- no data!");
      //manifestUpdating = NO;   
      return;
   }
   
   NSString *fileString = [[[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding] autorelease];
   // that came back as an HTML page on Nick's dataless phone!
   //twlog("parse manifest result:%@", fileString);
   NSString *plistID = @"<!DOCTYPE plist PUBLIC";
   if (![fileString contains:plistID])
   {
      twlog("parseManifestData -- bogus data!");
      [TWAppDelegate() bogusDataOffNet];
      return;
   }
   
   NSArray *manifest = [fileString propertyList];
   if (!manifest || ![manifest isKindOfClass:[NSArray class]] || !manifest.count)
   {
      twlog("parseManifestData -- bogus data! -- %@", manifest);
      //manifestUpdating = NO;   
      return;
   }

   if ([manifest isEqual:self.latestManifest])
   {
      twlog("parseManifestData -- equal, no changes needed");
      //manifestUpdating = NO;   
      return;
   }
   
   NSInteger currentVersion = 0;
   for (NSDictionary *currentEntry in self.latestManifest)
      if ([kTracksPlist isEqual:[currentEntry objectForKey:kManifestFile]])
      {
         currentVersion = [[currentEntry objectForKey:kManifestVersion] integerValue];
         break;
      }
   NSInteger onlineVersion = 0;
   for (NSDictionary *onlineEntry in manifest)
      if ([kTracksPlist isEqual:[onlineEntry objectForKey:kManifestFile]])
      {
         onlineVersion = [[onlineEntry objectForKey:kManifestVersion] integerValue];
         break;
      }
   if (onlineVersion < currentVersion)
   {
      twlog("parseManifestData -- online version older than bundle version!");
      //manifestUpdating = NO;   
      return;
   }
   
   twlog("parseManifestData: got something to update...");
   self.latestManifest = [manifest mutableCopy];

   for (NSDictionary *entry in self.installedManifest)
   {
      NSString *file = [entry objectForKey:kManifestFile];
      NSInteger version = [[entry objectForKey:kManifestVersion] integerValue];
      NSDictionary *latestEntry = [self latestEntry:file];
      NSInteger latestVersion = [[latestEntry objectForKey:kManifestVersion] integerValue];
      if (latestVersion <= version)
      {
         twlog("parseManifestData: version %d <= %d of %@", latestVersion, version, file);
         continue;
      }
      
#if YOGASLEEPLITE
      if ([file hasSuffix:@"caf"])
         if (![self isDownloadableTrack:file])
         {
            twlog("parseManifestData: %@ is not a downloadable track", file);
            continue;
         }
#endif //YOGASLEEPLITE
      
      NSString *fileLink = [kDropboxBaseLink stringByAppendingString:file];
      twlog("parseManifestData: downloading %@ version %d update to %d: %@", file, latestVersion, version, fileLink);
      ASIHTTPRequest *fileRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:fileLink]];
      fileRequest.userInfo = [latestEntry copy];
      NSString *downloadPath = [self.downloadsDirectory stringByAppendingPathComponent:file];
      [fileRequest setDownloadDestinationPath:downloadPath];
      [fileRequest setDelegate:self];
      fileRequest.didFinishSelector = @selector(fileRequestFinished:);
      fileRequest.didFailSelector = @selector(fileRequestFailed:);
      [self.downloadQueue addOperation:fileRequest];
   }
   //manifestUpdating = NO;
}

- (BOOL)isDownloadableTrack:(NSString *)file
{
   NSString *track = [[file lastPathComponent] stringByDeletingPathExtension];
   for (NSDictionary *playlist in self.basePlaylists)
   {
      NSArray *components = [playlist objectForKey:kPlaylistComponents];
      for (NSString *component in components)
         if ([component isEqual:track])
            return YES;
   }
   
   return NO;
}

- (NSDictionary *)latestEntry:(NSString *)file
//- (NSInteger)latestVersion:(NSString *)file
{
   for (NSDictionary *latestEntry in self.latestManifest)
      if ([file isEqual:[latestEntry objectForKey:kManifestFile]])
         //return [[latestEntry objectForKey:kManifestVersion] integerValue];
         return latestEntry;

   twlog("couldn't find latestVersion of %@!", file);
   return nil;
}

- (void)manifestRequestFailed:(ASIHTTPRequest *)request
{
   (void)request;
   twlog("manifestRequestFailed! -- %@", [request error]);
   //manifestUpdating = NO;   
}

- (void)fileRequestFinished:(ASIHTTPRequest *)request
{
   NSString *file = [request.userInfo objectForKey:kManifestFile];
   NSInteger version = [[request.userInfo objectForKey:kManifestVersion] integerValue];
  
   //NSString *file = [request.downloadDestinationPath lastPathComponent];
   //if ([file hasSuffix:@"caf"])
      //file = [kTracksSubfolder stringByAppendingPathComponent:file];
   NSString *finalPath = [self.documentDirectory stringByAppendingPathComponent:file];
   NSError *error = nil;
   BOOL copied = [[NSFileManager defaultManager] copyItemAtPath:request.downloadDestinationPath toPath:finalPath error:&error];
   
   if (!copied)
   {
      twlogif(!copied, "fileRequestFinished %@ copy err! -- %@", file, error);
      return;
   }
   
   for (NSMutableDictionary *entry in self.installedManifest)
      if ([file isEqual:[entry objectForKey:kManifestFile]])
      {
         twlog("updating saved file %@ to version %d", file, version);
         [entry setObject:[NSNumber numberWithInteger:version] forKey:kManifestVersion];
         
         NSString *manifestPath = [self.documentDirectory stringByAppendingPathComponent:kManifestPlist];
         BOOL wroteOK = [self.installedManifest writeToFile:manifestPath atomically:NO];
         twlogif(!wroteOK, "saving updated manifest failed!"); (void)wroteOK;

         break;
      }
}

- (void)fileRequestFailed:(ASIHTTPRequest *)request
{
   (void)request;
   twlog("fileRequestFailed! -- %@", [request error]);
}

/*
 - (NSString *)tracksPath
{
   NSString *tracksPath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"tracks"];
   return tracksPath;
}
 */

- (NSString *)pathForTrack:(NSString *)track
{
   if (!track.length)
      return nil;
   
   //NSString *pathForTrack = [self.tracksPath stringByAppendingPathComponent:track];
   NSString *subpath = [kTracksSubfolder stringByAppendingPathComponent:track];
   NSString *pathForTrack = [self pathForUpdatableFile:subpath];
   twcheck(pathForTrack.length);
   
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

- (NSString *)customPlaylistsPath
{
   NSString *customPlaylistsPath = [self.documentDirectory stringByAppendingPathComponent:@"customplaylists.plist"];
   return customPlaylistsPath;
}

- (void)saveCustomPlaylists
{
   BOOL wroteOK = [self.customPlaylists writeToFile:self.customPlaylistsPath atomically:NO];
   twlogif(!wroteOK, "saving custom playlists failed!"); (void)wroteOK;
}

- (NSMutableDictionary *)customPlaylistNamed:(NSString *)name
{
   //NSString *name = NSLocalizedString(@"CUSTOMPLAYLIST", nil);
   NSMutableDictionary *customPlaylist = nil;
   for (NSMutableDictionary *playlist in self.customPlaylists)
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
   for (NSMutableDictionary *playlist in self.customPlaylists)
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
      [self.customPlaylists removeObject:oldCustomPlaylist];
      playlistsChanged = YES;
   }
   
   // add new one if it has entries
   
   NSArray *components = [customPlaylist objectForKey:kPlaylistComponents];
   if (components.count)
   {
      [self.customPlaylists addObject:customPlaylist];
      playlistsChanged = YES;
   }
   
   // save if changed
   
   if (playlistsChanged)
   {
      [self combinePlaylists];
      [self saveCustomPlaylists];
   }
}

/*
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
*/
/*
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
*/

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
   [self.customPlaylists removeObject:playlist];
   [self combinePlaylists];
   [self saveCustomPlaylists];
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
      twlog("playing %@", filePath);
      [[SimpleAudioEngine sharedEngine] playBackgroundMusic:filePath loop:NO];
      playingPaused = NO;
   }
   else
   {
      NSString *message = self.downloadQueue.operations.count ? @"FILEWAIT" : @"FILEFAIL";
      [UIAlertView twxOKAlert:@"SORRY" withMessage:message];
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
