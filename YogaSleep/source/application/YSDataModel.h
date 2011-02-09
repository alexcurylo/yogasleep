//
//  YSDataModel.h
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

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

@interface YSDataModel : NSObject
{
   NSArray *tracks;
   NSMutableArray *playlists;
   NSString *documentDirectory;
   
   NSDictionary *playingPlaylist;
   //NSString *currentTrackID;
   NSInteger playingIndex;
   BOOL playingPaused;
 }

@property (nonatomic, retain) NSArray *tracks;
@property (nonatomic, retain) NSMutableArray *playlists;
@property (nonatomic, copy) NSString *documentDirectory;
@property (nonatomic, retain) NSDictionary *playingPlaylist;
@property (nonatomic, assign) NSInteger playingIndex;
//@property (nonatomic, copy) NSString *currentTrackID;

#pragma mark -
#pragma mark Life cycle

- (id)init;
- (void)dealloc;

#pragma mark -
#pragma mark Application support

- (UIBarButtonItem *)playingBarButtonForTarget:(id)target action:(SEL)action;

- (NSString *)tracksPath;
- (NSString *)pathForTrack:(NSString *)track;

- (NSDictionary *)trackWithID:(NSString *)trackID;
- (NSString *)pathForTrackID:(NSString *)trackID;

- (NSString *)playlistsPath;
- (void)savePlaylists;
- (void)loadPlaylists;

- (NSMutableDictionary *)customPlaylistNamed:(NSString *)name;
- (void)setCustomPlaylist:(NSMutableDictionary *)customPlaylist;
- (BOOL)hasCustomPlaylists;
- (NSArray *)customPlaylists;

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
