//
//  YSPlayerViewController.h
//
//  Copyright 2011 Trollwerks Inc. All rights reserved.
//

@class TWSecondsFormatter;

@interface YSPlayerViewController : UIViewController
{
   // in self.view
   IBOutlet UIImageView *albumArtworkImageView;
   IBOutlet UIView *playbackTopOverlayView;
      IBOutlet UILabel *playlistPositionLabel;
      IBOutlet UILabel *timeElapsedLabel;
      IBOutlet UILabel *timeRemainingLabel;
      IBOutlet UISlider *playbackPositionSlider;
   IBOutlet UIView *playbackBottomOverlayView;
      IBOutlet UIButton *previousSongButton;
      IBOutlet UIButton *playButton;
      IBOutlet UIButton *pauseButton;
      IBOutlet UIButton *nextSongButton;
      IBOutlet UIView *volumePlaceHolder;
      // MPVolumeView added in -viewDidLoad
   
/*
 // in self.navigationItem
	IBOutlet UIView *titleView;	
      IBOutlet UILabel *titleArtistLabel;
      IBOutlet UILabel *titleSongLabel;
      IBOutlet UILabel *titleAlbumLabel;
*/
   
   TWSecondsFormatter *secondsFormatter;
   NSTimer *updateTimer;
}

@property (nonatomic, retain) IBOutlet UIImageView *albumArtworkImageView;
@property (nonatomic, retain) IBOutlet UIView *playbackTopOverlayView;
@property (nonatomic, retain) IBOutlet UILabel *playlistPositionLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeElapsedLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeRemainingLabel;
@property (nonatomic, retain) IBOutlet UISlider *playbackPositionSlider;
@property (nonatomic, retain) IBOutlet UIView *playbackBottomOverlayView;
@property (nonatomic, retain) IBOutlet UIButton *previousSongButton;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *pauseButton;
@property (nonatomic, retain) IBOutlet UIButton *nextSongButton;
@property (nonatomic, retain) IBOutlet UIView *volumePlaceHolder;
/*
 @property (nonatomic, retain) IBOutlet UIView *titleView;
@property (nonatomic, retain) IBOutlet UILabel *titleArtistLabel;
@property (nonatomic, retain) IBOutlet UILabel *titleSongLabel;
@property (nonatomic, retain) IBOutlet UILabel *titleAlbumLabel;
*/
@property (nonatomic, retain) TWSecondsFormatter *secondsFormatter;
@property (nonatomic, retain) NSTimer *updateTimer;

+ (YSPlayerViewController *)controller;

- (void)viewDidLoad;
- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void)didReceiveMemoryWarning;
- (void)viewDidUnload;
- (void)setView:(UIView *)toView;
- (void)clearOutlets;
- (void)dealloc;

- (void)timerFireMethod:(NSTimer*)theTimer;
- (void)songChanged:(NSNotification*)notification;
- (void)updateSongView;
- (void)updateSongPosition;

- (IBAction)previousSong:(id)sender;
- (IBAction)nextSong:(id)sender;
- (IBAction)playSong:(id)sender;
- (IBAction)pauseSong:(id)sender;
- (IBAction)playbackPositionSlid:(id)sender;

- (void)showInfo;
- (void)navigateBack;

@end
