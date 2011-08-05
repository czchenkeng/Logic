//
//  ScoreCell.h
//  Logic
//
//  Created by Pavel Krusek on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Score.h"
#import "ShadowedLabel.h"


@interface ScoreCell : UITableViewCell {
    ShadowedLabel *idLabel;
	ShadowedLabel *scoreLabel;
    ShadowedLabel *timeLabel;
	ShadowedLabel *dateLabel;
}

@property (nonatomic, retain) ShadowedLabel *idLabel;
@property (nonatomic, retain) ShadowedLabel *scoreLabel;
@property (nonatomic, retain) ShadowedLabel *timeLabel;
@property (nonatomic, retain) ShadowedLabel *dateLabel;

-(void)setData:(Score *)score;
-(UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold;

@end