//
//  YSRecordingViewController.h
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

@class YSRecordingTableViewCell;

@interface YSRecordingViewController : UIViewController
{
   IBOutlet UITextView *moreInfo;
   IBOutlet UITableView *tracksTable;
   
   IBOutlet YSRecordingTableViewCell *templateCell;

   NSDictionary *playlist;
}

@property (nonatomic, retain) IBOutlet UITextView *moreInfo;
@property (nonatomic, retain) IBOutlet UITableView *tracksTable;
@property (nonatomic, assign) IBOutlet YSRecordingTableViewCell *templateCell;
@property (nonatomic, retain) NSDictionary *playlist;

#pragma mark -
#pragma mark Life cycle

+ (YSRecordingViewController *)controllerForRecording:(NSInteger)idx;

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

- (void)play;
- (void)pause;
- (void)showPlayer;

- (void)trackChanged:(NSNotification *)note;

#pragma mark -
#pragma mark Table support

- (NSDictionary *)componentAtIndex:(NSInteger)idx;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;

@end
