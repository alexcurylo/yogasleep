//
//  YSCustomRecordingsViewController.h
//
//  Copyright Trollwerks Inc 2011. All rights reserved.
//

#include "YSRecordingsViewController.h"

@interface YSCustomRecordingsViewController : YSRecordingsViewController < UITextFieldDelegate >
{
   IBOutlet UIView *nameView;
   IBOutlet UITextField *nameField;
}

@property (nonatomic, retain) IBOutlet UIView *nameView;
@property (nonatomic, retain) IBOutlet UITextField *nameField;

#pragma mark -
#pragma mark Life cycle

+ (YSCustomRecordingsViewController *)controller;

- (void)viewWillAppear:(BOOL)animated;
- (void)clearOutlets;
- (void)dealloc;

#pragma mark -
#pragma mark Actions

- (IBAction)addPlaylist;

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (void)textFieldDidEndEditing:(UITextField *)textField;

#pragma mark -
#pragma mark Table support

- (NSArray *)recordingsList;
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;

@end
