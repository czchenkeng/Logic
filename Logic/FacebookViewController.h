//
//  FacebookViewController.h
//  Logic
//
//  Created by Pavel Krusek on 7/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FBConnect.h"


@interface FacebookViewController : UIViewController <FBRequestDelegate, FBDialogDelegate, FBSessionDelegate> {
    struct CGRect rect;
    UIView *loginView;
    
    Facebook *_facebook;
    NSArray *_permissions;
}

@property (nonatomic, retain) UIView *loginView;
@property (readonly) Facebook *facebook;

- (id) initWithFrame:(CGRect)_rect;

@end
