//
//  YSRecordingsViewController.h
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

@class YSRecordingTableViewCell;

@interface YSRecordingsViewController : UIViewController
{
   IBOutlet UITextView *moreInfo;
   IBOutlet UITableView *recordingsTable;
   
   IBOutlet YSRecordingTableViewCell *templateCell;
}

@property (nonatomic, retain) IBOutlet UITextView *moreInfo;
@property (nonatomic, retain) IBOutlet UITableView *recordingsTable;
@property (nonatomic, assign) IBOutlet YSRecordingTableViewCell *templateCell;

#pragma mark -
#pragma mark Life cycle

+ (YSRecordingsViewController *)controller;

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


#pragma mark -
#pragma mark Table support

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;

@end
