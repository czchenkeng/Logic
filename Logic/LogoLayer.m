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
    singleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)] autorelease];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    
    singleTap.cancelsTouchesInView = NO;
    
    singleTap.delegate = self;
    
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:singleTap];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Flow1280x1920_VO_ver3" ofType:@"mp4"];
    NSURL *movieURL = [NSURL fileURLWithPath:path];
    
    mp = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
    [mp moviePlayer].controlStyle = MPMovieControlStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerLoadStateChanged:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedPlaying:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];    
    
    [super onEnter];
}

- (void) onExit {
    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:singleTap];
    [super onExit];
}

- (void) handleSingleTap:(UITapGestureRecognizer *)recognizer {
    CCLOG(@"HANDLER KONEC LOGA");
    [[mp moviePlayer] stop];
    [[GameManager sharedGameManager] runSceneWithID:kPreloaderScene andTransition:kNoTransition];
}


- (void) moviePlayerLoadStateChanged:(NSNotification*)notification {
    
    CCLOG(@"moviePlayerLoadStateChanged");
    
    if ([mp moviePlayer].loadState != MPMovieLoadStateUnknown) {        
        if ([mp moviePlayer].loadState != MPMovieLoadStatePlaythroughOK) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
            [[[[CCDirector sharedDirector] openGLView] window] addSubview:mp.view];
            [[mp moviePlayer] play];
        }
    } else if ([mp moviePlayer].loadState == MPMovieLoadStateUnknown) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
        [[GameManager sharedGameManager] runSceneWithID:kPreloaderScene andTransition:kNoTransition];
    }
    
}

- (void) movieFinishedPlaying:(NSNotification*)notification {    
    CCLOG(@"movie finish");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [mp.view removeFromSuperview];
    [[GameManager sharedGameManager] runSceneWithID:kPreloaderScene andTransition:kNoTransition];
}


- (void)dealloc {
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    [mp release];
    mp = nil;
    [super dealloc];
}

@end
