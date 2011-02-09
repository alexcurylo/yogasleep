//
//  YSRecordingTableViewCell.h
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

#import "YSRecordingTableViewCell.h"
#import "TWNavigationAppDelegate.h"
//#import "RRLatestNewsViewController.h"
//#import "TWXUIColor.h"
//#import "NSDate+Helper.h"

@implementation YSRecordingTableViewCell

//@synthesize headlineLabel;
//@synthesize detailLabel;
//@synthesize typeImage;
@synthesize nameLabel;
@synthesize timeLabel;
@synthesize categoryLabel;
@synthesize textColor;
@synthesize trackID;

- (void)awakeFromNib
{
   [super awakeFromNib];
   
   self.textColor = [UIColor blackColor];
   
   // should never see this more than number of cells on screen at once
   // if you do, probably forgot to fix identifier in nib
   //twlog("awoken!");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
   [super setSelected:selected animated:animated];

   /*
    if ([TWDataModel() isCurrentTrack:self.trackID])
   {
		self.nameLabel.textColor = [UIColor redColor]; 
		self.timeLabel.textColor = [UIColor redColor]; 
		self.categoryLabel.textColor = [UIColor redColor]; 
   }
   else
    */
   if (selected)
   {
		//self.headlineLabel.textColor = [UIColor whiteColor]; 
		//self.detailLabel.textColor = [UIColor whiteColor]; 
		//self.timeLabel.textColor = [UIColor whiteColor]; 
		self.nameLabel.textColor = [UIColor whiteColor]; 
		self.timeLabel.textColor = [UIColor whiteColor]; 
		self.categoryLabel.textColor = [UIColor whiteColor]; 
   }
   else
   {
		//self.headlineLabel.textColor = [UIColor blackColor]; 
		//self.detailLabel.textColor = [UIColor darkGrayColor];
      // from Photoshop
		//self.timeLabel.textColor = [UIColor colorFromHexValue:0x309BD2]; 
		self.nameLabel.textColor = self.textColor; 
		self.timeLabel.textColor = self.textColor; 
		self.categoryLabel.textColor = self.textColor; 
   }
}

- (void)dealloc
{
	//self.headlineLabel = nil;
	//self.detailLabel = nil;
	//self.typeImage = nil;
	//self.timeLabel = nil;
   twrelease(nameLabel);
   twrelease(timeLabel);
   twrelease(categoryLabel);
   twrelease(textColor);
   twrelease(trackID);

   [super dealloc];
}

- (void)setStringsColor:(UIColor *)color
{
   self.textColor = color;
}

/*
- (void)fillOutWith:(NSDictionary *)eventInfo andImage:(UIImage *)image
{
   self.typeImage.image = image;

   NSString *headline = [eventInfo objectForKey:kNewsTitleEntry];
   self.headlineLabel.text = headline;

   NSString *detail = [eventInfo objectForKey:kNewsTextEntry];
   self.detailLabel.text = detail;

   NSString *dateString = [eventInfo objectForKey:kNewsDateEntry];
   
   // http://www.alexcurylo.com/blog/2009/01/29/nsdateformatter-formatting/
   NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
   //         date = "Sat, 01 May 2010 18:38:10 PDT";
   [formatter setDateFormat:@"ccc, dd MMM yyyy H:m:s z"];
   [formatter setTimeZone:[NSTimeZone systemTimeZone]];
   NSDate *when = [formatter dateFromString:dateString];
   //twlog("dateString: %@ formattedDate: %@", dateString, when);
   
   /// *
    [formatter setDateFormat:@"MMM"];
   self.monthLabel.text = [formatter stringFromDate:when].uppercaseString;

   [formatter setDateFormat:@"d"];
   self.dayLabel.text = [formatter stringFromDate:when];
    
    [formatter setDateFormat:@"h:mm a"];
    self.timeLabel.text = [formatter stringFromDate:when];
    // * /
   
   self.timeLabel.text = [when stringTimeAgo];
   
   // http://www.codeproject.com/Articles/41906/Formatting-Dates-relative-to-Now-Objective-C-iPhon.aspx
}
*/

- (void)fixNumberOfLines
{
   self.nameLabel.font = [UIFont boldSystemFontOfSize:kCellNameSize];
   //self.nameLabel.numberOfLines = ceilf([self.nameLabel.text sizeWithFont:self.nameLabel.font constrainedToSize:CGSizeMake(kCellNameWidth, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap].height/20.0);
   // looks like we can just make this a big number and it'll lay out correctly?
   self.nameLabel.numberOfLines = 5;
}

//- (void)fillOutWithPlaylist:(NSInteger)idx
- (void)fillOutWithPlaylist:(NSDictionary *)playlist
{
   //NSDictionary *playlist = [TWDataModel().playlists objectAtIndex:idx];

   NSString *name = [playlist objectForKey:kPlaylistName];
   self.nameLabel.text = name;
   [self fixNumberOfLines];

   NSInteger seconds = [[playlist objectForKey:kPlaylistTime] integerValue];
   NSString *timeString = [NSString stringWithFormat:NSLocalizedString(@"TIMEFORMATMIN", nil),
      seconds / 60,
      seconds % 60
   ];
   self.timeLabel.text = timeString;

   NSString *category = [playlist objectForKey:kPlaylistCategory];
   self.categoryLabel.text = category;
}

/*
- (void)fillOutWithDataModelTrack:(NSInteger)idx
{
   NSDictionary *track = [TWDataModel().tracks objectAtIndex:idx];
   [self fillOutWithTrackDictionary:track];
}
*/

- (void)fillOutWithTrack:(NSInteger)idx fromPlaylist:(NSDictionary *)playlist
{
   NSArray *components = [playlist objectForKey:kPlaylistComponents];
   self.trackID = [components objectAtIndex:idx];
   NSDictionary *component = [TWDataModel() trackWithID:self.trackID];
   [self fillOutWithTrackDictionary:component];
}

- (void)fillOutWithTrackDictionary:(NSDictionary *)track
{
   NSString *name = [track objectForKey:kTrackName];
   self.nameLabel.text = name;
   [self fixNumberOfLines];

   NSInteger seconds = [[track objectForKey:kTrackTime] integerValue];
   NSString *timeString = nil;
   if (59 < seconds)
   {
      timeString = [NSString stringWithFormat:NSLocalizedString(@"TIMEFORMATMINSEC", nil),
         seconds / 60,
         seconds % 60
      ];
   }
   else
   {
      timeString = [NSString stringWithFormat:NSLocalizedString(@"TIMEFORMATSEC", nil),
         seconds % 60
      ];
   }
   self.timeLabel.text = timeString;

   NSString *category = [track objectForKey:kTrackCategory];
   self.categoryLabel.text = category;
}

@end
