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
    Facebook *_facebook;
    NSArray *_permissions;
    NSString *_accessToken;
    int logicScore;
    NSString *fbText;
}

@property (readonly) Facebook *facebook;

- (void) login:(int)score fbText:(NSString *)fbTxt;

@end
