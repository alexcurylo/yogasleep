//
//  YSRecordingTableViewCell.h
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

@interface YSRecordingTableViewCell : UITableViewCell
{
	//IBOutlet UILabel *headlineLabel;
	//IBOutlet UILabel *detailLabel;
	//IBOutlet UIImageView *typeImage;
	IBOutlet UILabel *nameLabel;
	IBOutlet UILabel *timeLabel;
	IBOutlet UILabel *categoryLabel;
   
   NSString *trackID;
}

//@property (nonatomic, retain) IBOutlet UILabel *headlineLabel;
//@property (nonatomic, retain) IBOutlet UILabel *detailLabel;
//@property (nonatomic, retain) IBOutlet UIImageView *typeImage;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *categoryLabel;
@property (nonatomic, copy) NSString *trackID;

- (void)awakeFromNib;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
- (void)dealloc;

//- (void)fillOutWith:(NSDictionary *)eventInfo andImage:(UIImage *)image;
- (void)fillOutWithPlaylist:(NSInteger)idx;
- (void)fillOutWithDataModelTrack:(NSInteger)idx;
- (void)fillOutWithTrack:(NSInteger)idx fromPlaylist:(NSDictionary *)playlist;
- (void)fillOutWithTrackDictionary:(NSDictionary *)track;

@end
