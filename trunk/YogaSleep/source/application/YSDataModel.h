//
//  YSDataModel.h
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

#import "ASIHTTPRequestDelegate.h"
#import "ASINetworkQueue.h"

#define REQUEST_MANIFEST_NSURLCONNECTION 1
// perhaps NSURLConnection will handle Nick's no data plan 3G phone and not crash with no wifi
#if REQUEST_MANIFEST_NSURLCONNECTION
#import "TWURLFetcher.h"
#endif //REQUEST_MANIFEST_NSURLCONNECTION

extern NSString *kTrackName; // = @"name";
extern NSString *kTrackID; // = @"id";
extern NSString *kTrackTime; // = @"time";
extern NSString *kTrackCategory; // = @"category";
extern NSString *kTrackDescription; // = @"description";
extern NSString *kTrackFile; // = @"file";

extern NSString *kPlaylistEditable; // = @"editable";
extern NSString *kPlaylistName; // = @"name";
extern NSString *kPlaylistTime; // = @"time";
extern NSString *kPlaylistCategory; // = @"category";
extern NSString *kPlaylistDescription; // = @"description";
extern NSString *kPlaylistComponents; // = @"components";

extern NSString *kTrackChangeNotification; // = @"TrackChange";

enum
{
   kNoTrackPlaying = -1,
};

@interface YSDataModel : NSObject < ASIHTTPRequestDelegate >
{
   NSArray *tracks;
   NSArray *basePlaylists;
   NSMutableArray *customPlaylists;
   NSMutableArray *combinedPlaylists;
   NSMutableArray *installedManifest;
   NSMutableArray *latestManifest;
   NSString *documentDirectory;
   NSString *downloadsDirectory;

   NSDictionary *playingPlaylist;
   NSInteger playingIndex;
   BOOL playingPaused;
   
   //BOOL manifestUpdating;
   ASINetworkQueue *downloadQueue;
}

@property (nonatomic, retain) NSArray *tracks;
@property (nonatomic, retain) NSArray *basePlaylists;
@property (nonatomic, retain) NSMutableArray *customPlaylists;
@property (nonatomic, retain) NSMutableArray *combinedPlaylists;
@property (nonatomic, retain) NSMutableArray *installedManifest;
@property (nonatomic, retain) NSMutableArray *latestManifest;
@property (nonatomic, copy) NSString *documentDirectory;
@property (nonatomic, copy) NSString *downloadsDirectory;
@property (nonatomic, retain) NSDictionary *playingPlaylist;
@property (nonatomic, assign) NSInteger playingIndex;
@property (retain) ASINetworkQueue *downloadQueue;

#pragma mark -
#pragma mark Life cycle

- (id)init;
- (void)initDownloadQueue;
- (void)cleanDownloadQueue;
- (void)dealloc;

#pragma mark -
#pragma mark Application support

- (UIBarButtonItem *)playingBarButtonForTarget:(id)target action:(SEL)action;

- (NSString *)pathForUpdatableFile:(NSString *)file;
- (void)loadManifest;
- (void)loadTracks;
- (void)loadPlaylists;
- (void)combinePlaylists;

- (void)checkForDownloadableTracks;

- (void)updateManifest;
#if REQUEST_MANIFEST_NSURLCONNECTION
- (void)fetchedManifest:(TWURLFetcher *)fetcher;
#else
- (void)manifestRequestFinished:(ASIHTTPRequest *)request;
#endif //REQUEST_MANIFEST_NSURLCONNECTION
- (void)parseManifestData:(NSData *)fileData;
- (BOOL)isDownloadableTrack:(NSString *)file;
- (NSDictionary *)latestEntry:(NSString *)file;
//- (NSInteger)latestVersion:(NSString *)file;
- (void)manifestRequestFailed:(ASIHTTPRequest *)request;
- (void)fileRequestFinished:(ASIHTTPRequest *)request;
- (void)fileRequestFailed:(ASIHTTPRequest *)request;

//- (NSString *)tracksPath;
- (NSString *)pathForTrack:(NSString *)track;
- (NSDictionary *)trackWithID:(NSString *)trackID;
- (NSString *)pathForTrackID:(NSString *)trackID;

- (NSString *)customPlaylistsPath;
- (void)saveCustomPlaylists;

- (NSMutableDictionary *)customPlaylistNamed:(NSString *)name;
- (void)setCustomPlaylist:(NSMutableDictionary *)customPlaylist;
//- (BOOL)hasCustomPlaylists;
//- (NSArray *)customPlaylists;

//- (void)removePlaylist:(NSUInteger)idx;
- (void)removePlaylist:(NSDictionary *)playlist;

- (BOOL)isPlayingPlaylist:(NSDictionary *)playlist;
//- (BOOL)isCurrentTrack:(NSString *)trackID;
- (NSDictionary *)currentTrack;
- (NSInteger)trackCount;

- (void)togglePlayPause;
- (void)play:(NSDictionary *)playlist;
- (void)startAudio;
- (void)pause:(NSDictionary *)playlist;
- (void)previousTrack;
- (void)nextTrack;

- (void)trackFinished;
- (void)changeTrackBy:(NSInteger)delta;

@end
