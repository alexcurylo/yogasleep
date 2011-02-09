//
//  YSCreateViewController.h
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

@class YSRecordingTableViewCell;

enum
{
   kSectionCustomPlaylist = 0,
   //kSectionAddableTracks,
   kCreateSectionsCount,
};

@interface YSCreateViewController : UIViewController
{
   IBOutlet UITextView *moreInfo;
   IBOutlet UITableView *createTable;
   
   IBOutlet YSRecordingTableViewCell *templateCell;
   
   NSString *playlistName;
   NSMutableDictionary *playlist;
}

@property (nonatomic, retain) IBOutlet UITextView *moreInfo;
@property (nonatomic, retain) IBOutlet UITableView *createTable;
@property (nonatomic, assign) IBOutlet YSRecordingTableViewCell *templateCell;
@property (nonatomic, copy) NSString *playlistName;
@property (nonatomic, retain) NSMutableDictionary *playlist;

#pragma mark -
#pragma mark Life cycle

+ (YSCreateViewController *)controllerWithName:(NSString *)name;

- (void)viewDidLoad;
- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)didReceiveMemoryWarning;
- (void)viewDidUnload;
- (void)setView:(UIView*)toView;
- (void)clearOutlets;
- (void)dealloc;

#pragma mark -
#pragma mark Actions

- (void)fixPlayControls;

- (IBAction)addTracks;

- (void)play;
- (void)pause;
- (void)showPlayer;

- (void)trackChanged:(NSNotification *)note;

- (void)addTrack:(NSIndexPath *)indexPath;
- (void)removeTrack:(NSIndexPath *)indexPath;
- (void)moveTrack:(NSInteger)idx to:(NSInteger)newIdx;

#pragma mark -
#pragma mark Table support

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath;
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;

@end
