//
//  YSCustomRecordingsViewController.m
//
//  Copyright Trollwerks Inc 2011. All rights reserved.
//

#import "YSCustomRecordingsViewController.h"
#import "TWNavigationAppDelegate.h"
#import "YSCreateViewController.h"
#import "YSAddViewController.h"

@implementation YSCustomRecordingsViewController

@synthesize nameView;
@synthesize nameField;

#pragma mark -
#pragma mark Life cycle

+ (YSCustomRecordingsViewController *)controller
{
   YSCustomRecordingsViewController *controller = [[[YSCustomRecordingsViewController alloc] initWithNibName:@"YSCustomRecordingsView" bundle:nil] autorelease];
   controller.title = NSLocalizedString(@"TITLECREATE", nil);
   return controller;
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
   
   [self.recordingsTable reloadData];
   
   if (TWDataModel().hasCustomPlaylists)
      self.moreInfo.text = NSLocalizedString(@"INFOCUSTOM", nil);
   else
      self.moreInfo.text = NSLocalizedString(@"INFONOCUSTOM", nil);
}

- (void)clearOutlets
{
   self.nameView = nil;
   self.nameField = nil;

   [super clearOutlets];
}

- (void)dealloc
{   
   twrelease(nameView);
   twrelease(nameField);
   
   [super dealloc];
}

#pragma mark -
#pragma mark Actions

- (IBAction)addPlaylist
{
   [self.view addSubview:self.nameView];
   self.nameView.center = CGPointMake(160, 160);
   [self.nameField becomeFirstResponder];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
   [textField resignFirstResponder];
   return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
   NSString *newName = textField.text;
   
   [self.nameView removeFromSuperview];

   if (newName.length)
   {
      [self.navigationController pushViewController:[YSCreateViewController controllerWithName:newName] animated:NO];
      [self.navigationController pushViewController:[YSAddViewController controllerWithName:newName] animated:YES];
   }
}

#pragma mark -
#pragma mark Table support

- (NSArray *)recordingsList
{
   return TWDataModel().customPlaylists;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
 	(void)tableView;
   
   NSDictionary *playlist = [self.recordingsList objectAtIndex:indexPath.row];
   NSString *name = [playlist objectForKey:kPlaylistName];

   [self.navigationController pushViewController:[YSCreateViewController controllerWithName:name] animated:YES];
}

@end

