//
//  ScoreCell.h
//  Logic
//
//  Created by Pavel Krusek on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Score.h" 


@interface ScoreCell : UITableViewCell {
    UILabel *idLabel;
	UILabel *scoreLabel;
    UILabel *timeLabel;
	UILabel *dateLabel;
}

@property (nonatomic, retain) UILabel *idLabel;
@property (nonatomic, retain) UILabel *scoreLabel;
@property (nonatomic, retain) UILabel *timeLabel;
@property (nonatomic, retain) UILabel *dateLabel;

-(void)setData:(Score *)score;
-(UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold;

@end