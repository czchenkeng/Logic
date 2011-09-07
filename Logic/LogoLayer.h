//
//  LogoLayer.h
//  Logic
//
//  Created by Apple on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface LogoLayer : CCLayer <UIGestureRecognizerDelegate> {
    
    UITapGestureRecognizer *singleTap;
    MPMoviePlayerViewController *mp;
    
}

@end
