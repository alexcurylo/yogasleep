//
//  TWRootTableViewController.m
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

#import "TWRootTableViewController.h"

@implementation TWRootTableViewController

#pragma mark -
#pragma mark Life cycle

+ (TWRootTableViewController *)controller
{
   TWRootTableViewController *controller = [[[TWRootTableViewController alloc] initWithNibName:@"TWRootTableView" bundle:nil] autorelease];
   controller.title = NSLocalizedString(@"TITLEROOTTABLE", nil);
   return controller;
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   twlog("TWRootTableViewController viewDidLoad");

#if SUPPORTOS2TABLEVIEWCELLS
   UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"TEST"] autorelease];
   hasInitWithStyle = [cell respondsToSelector:@selector(initWithStyle:reuseIdentifier:)];
#endif SUPPORTOS2TABLEVIEWCELLS
   
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
   [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];
   //[TWAppDelegate() showIntroAlert:@"INTROTABLE"];
}

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];

   twlog("TWRootTableViewController didReceiveMemoryWarning -- no action");
}

- (void)viewDidUnload
{
   twlog("TWRootTableViewController viewDidUnload");
	[self clearOutlets];
}

- (void)setView:(UIView*)toView
{
	if (!toView)
		[self clearOutlets];
	
	[super setView:toView];
}

- (void)clearOutlets
{
}

- (void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   [self clearOutlets];

   [super dealloc];
}

#pragma mark -
#pragma mark Actions


#pragma mark -
#pragma mark Table support

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	(void)tableView;
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	(void)tableView;
	(void)section;
	
   return @"Untitled Section";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   (void)tableView;
 	(void)section;
   
   return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kRootTableViewCellIdentifier = @"RootTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRootTableViewCellIdentifier];
    if (cell == nil)
    {
#if SUPPORTOS2TABLEVIEWCELLS
       if (!hasInitWithStyle)
          cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kRootTableViewCellIdentifier] autorelease];
       else
#endif SUPPORTOS2TABLEVIEWCELLS
          cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kRootTableViewCellIdentifier] autorelease];
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
   NSString *mainLabel = [NSString stringWithFormat:@"cell %i", indexPath.row];
#if SUPPORTOS2TABLEVIEWCELLS
   if (!hasInitWithStyle)
      cell.text = mainLabel;
   else
#endif SUPPORTOS2TABLEVIEWCELLS
      cell.textLabel.text = mainLabel;

   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 	(void)tableView;

   // Navigation logic may go here -- for example, create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController animated:YES];
	// [anotherViewController release];
   
   // or treat it as an accessory tap perhaps
   // [self tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
   
   twlog("selected row %i", indexPath.row);
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
 	(void)tableView;

   twlog("accessory button tapped for row %i", indexPath.row);
}

@end

