//
//  LogoLayer.m
//  Logic
//
//  Created by Apple on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LogoLayer.h"


@implementation LogoLayer

- (id) init {
    self = [super init];
    if (self != nil) {
        CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    }
    return self;
}

- (void) onEnter {    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Flow1280x1920_VO_ver3" ofType:@"mp4"];
    NSURL *movieURL = [NSURL fileURLWithPath:path];
    
    mp = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
    [mp moviePlayer].controlStyle = MPMovieControlStyleNone;
    
    overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    singleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)] autorelease];
    [overlayView addGestureRecognizer:singleTap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerLoadStateChanged:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedPlaying:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];    
    
    [super onEnter];
}

- (void) onExit {
    [overlayView removeGestureRecognizer:singleTap];
    [super onExit];
}

- (void) handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [[mp moviePlayer] stop];
    [[GameManager sharedGameManager] runSceneWithID:kPreloaderScene andTransition:kNoTransition];
}


- (void) moviePlayerLoadStateChanged:(NSNotification*)notification {
    if ([mp moviePlayer].loadState != MPMovieLoadStateUnknown) {        
        if ([mp moviePlayer].loadState != MPMovieLoadStatePlaythroughOK) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
            [[[[CCDirector sharedDirector] openGLView] window] insertSubview:mp.view atIndex:1];
            
            overlayView.backgroundColor = [UIColor clearColor];
            [[[[CCDirector sharedDirector] openGLView] window] insertSubview:overlayView atIndex:2];
            
            [[mp moviePlayer] play];
        }
    } else if ([mp moviePlayer].loadState == MPMovieLoadStateUnknown) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
        [[GameManager sharedGameManager] runSceneWithID:kPreloaderScene andTransition:kNoTransition];
    }
    
}

- (void) movieFinishedPlaying:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [overlayView removeFromSuperview];
    [mp.view removeFromSuperview];
    [[GameManager sharedGameManager] runSceneWithID:kPreloaderScene andTransition:kNoTransition];
}


- (void)dealloc {
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    [overlayView release];
    overlayView = nil;
    [mp release];
    mp = nil;
    [super dealloc];
}

@end
