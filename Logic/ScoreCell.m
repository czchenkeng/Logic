//
//  ScoreCell.m
//  Logic
//
//  Created by Pavel Krusek on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScoreCell.h"


@implementation ScoreCell

@synthesize idLabel, scoreLabel, timeLabel, dateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *myContentView = self.contentView;
        
        //self.idLabel = [self newLabelWithPrimaryColor:[UIColor whiteColor] selectedColor:[UIColor whiteColor] fontSize:10.0 bold:NO];
//        self.idLabel = [[UILabel alloc] init];
//        self.idLabel.textColor = [UIColor whiteColor];
//        self.idLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.75];
//        self.idLabel.shadowOffset = CGSizeMake(5.0, -5.0);
//		self.idLabel.textAlignment = UITextAlignmentLeft; // default
//        self.idLabel.backgroundColor = [UIColor clearColor];
//        self.idLabel.font = [UIFont fontWithName:@"BellGothicStd-Bold" size:14];
//		//[myContentView addSubview:self.idLabel];
//		[self.idLabel release];
		

        //self.scoreLabel = [self newLabelWithPrimaryColor:[UIColor whiteColor] selectedColor:[UIColor whiteColor] fontSize:10.0 bold:NO];
//        self.scoreLabel = [[UILabel alloc] init];
//        self.scoreLabel.textColor = [UIColor whiteColor];
//        self.scoreLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.75];
//        self.scoreLabel.shadowOffset = CGSizeMake(5.0, -5.0);
//		self.scoreLabel.textAlignment = UITextAlignmentLeft; // default
//        self.scoreLabel.backgroundColor=[UIColor clearColor];
//        self.scoreLabel.font = [UIFont fontWithName:@"BellGothicStd-Bold" size:14];
//		[myContentView addSubview:self.scoreLabel];
//		[self.scoreLabel release];
        
        self.idLabel = [[[ShadowedLabel alloc] init] autorelease];
        self.idLabel.font = [UIFont fontWithName:@"BellGothicStd-Bold" size:14];
        self.idLabel.backgroundColor = [UIColor clearColor];
        self.idLabel.textColor = [UIColor whiteColor];
        [myContentView addSubview:self.idLabel];

        
        self.scoreLabel = [[[ShadowedLabel alloc] init] autorelease];
        self.scoreLabel.font = [UIFont fontWithName:@"BellGothicStd-Bold" size:14];
        self.scoreLabel.backgroundColor = [UIColor clearColor];
        self.scoreLabel.textAlignment = UITextAlignmentRight;
        self.scoreLabel.textColor = [UIColor whiteColor];
        [myContentView addSubview:self.scoreLabel];
        
        self.timeLabel = [[[ShadowedLabel alloc] init] autorelease];
        self.timeLabel.font = [UIFont fontWithName:@"BellGothicStd-Bold" size:14];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textAlignment = UITextAlignmentRight;
        self.timeLabel.textColor = [UIColor whiteColor];
        [myContentView addSubview:self.timeLabel];
        
        self.dateLabel = [[[ShadowedLabel alloc] init] autorelease];
        self.dateLabel.font = [UIFont fontWithName:@"BellGothicStd-Bold" size:14];
        self.dateLabel.backgroundColor = [UIColor clearColor];
        self.dateLabel.textAlignment = UITextAlignmentRight;
        self.dateLabel.textColor = [UIColor whiteColor];
        [myContentView addSubview:self.dateLabel];
        
        
//        //self.timeLabel = [self newLabelWithPrimaryColor:[UIColor whiteColor] selectedColor:[UIColor whiteColor] fontSize:10.0 bold:NO];
//        self.timeLabel = [[UILabel alloc] init];
//        self.timeLabel.textColor = [UIColor whiteColor];
//        self.timeLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.75];
//        self.timeLabel.shadowOffset = CGSizeMake(5.0, -5.0);
//		self.timeLabel.textAlignment = UITextAlignmentLeft; // default
//        self.timeLabel.backgroundColor=[UIColor clearColor];
//        self.timeLabel.font = [UIFont fontWithName:@"BellGothicStd-Bold" size:14];
//		//[myContentView addSubview:self.timeLabel];
//		[self.timeLabel release];
//        
//        //self.dateLabel = [self newLabelWithPrimaryColor:[UIColor whiteColor] selectedColor:[UIColor whiteColor] fontSize:10.0 bold:NO];
//        self.dateLabel = [[UILabel alloc] init];
//        self.dateLabel.textColor = [UIColor whiteColor];
//        self.dateLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.75];
//        self.dateLabel.shadowOffset = CGSizeMake(5.0, -5.0);
//		self.dateLabel.textAlignment = UITextAlignmentLeft; // default
//        self.dateLabel.backgroundColor=[UIColor clearColor];
//        self.dateLabel.font = [UIFont fontWithName:@"BellGothicStd-Bold" size:14];
//		//[myContentView addSubview:self.dateLabel];
//		[self.dateLabel release];
        
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
	
    CGRect contentRect = self.contentView.bounds;
	
    if (!self.editing) {
		
        CGFloat boundsX = contentRect.origin.x;
		CGRect frame;
        
		frame = CGRectMake(boundsX + 15, 4, 200, 20);
		self.idLabel.frame = frame;

		frame = CGRectMake(boundsX + 25, 4, 90, 20);
		self.scoreLabel.frame = frame;
        
        frame = CGRectMake(boundsX + 125, 4, 60, 20);
		self.timeLabel.frame = frame;
        
        frame = CGRectMake(boundsX + 190, 4, 60, 20);
		self.dateLabel.frame = frame;
	}
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setData:(Score *)score {
	self.idLabel.text = score.uniqueId;
	self.scoreLabel.text = score.score;
    self.timeLabel.text = score.time;
    self.dateLabel.text = score.date;
}

- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold
{
	/*
	 Create and configure a label.
	 */
	
    UIFont *font;
    if (bold) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    } else {
        font = [UIFont systemFontOfSize:fontSize];
    }
    
    /*
	 Views are drawn most efficiently when they are opaque and do not have a clear background, so set these defaults.  To show selection properly, however, the views need to be transparent (so that the selection color shows through).  This is handled in setSelected:animated:.
	 */
	UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	newLabel.backgroundColor = [UIColor whiteColor];
	newLabel.opaque = YES;
	newLabel.textColor = primaryColor;
	newLabel.highlightedTextColor = selectedColor;
	newLabel.font = font;
	
	return newLabel;
}

- (void)dealloc
{
//    [idLabel dealloc];
//	[scoreLabel dealloc];
//    [timeLabel dealloc];
//    [dateLabel dealloc];
    [super dealloc];
}

@end
