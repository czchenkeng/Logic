//
//  FacebookViewController.m
//  Logic
//
//  Created by Pavel Krusek on 7/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FacebookViewController.h"


@implementation FacebookViewController
@synthesize loginView;
@synthesize facebook = _facebook;
static NSString *kAppId = @"237730952923005";

- (id) initWithFrame:(CGRect)_rect {
    self = [super init];
    if (self != nil) {
        rect = _rect;
        _permissions =  [[NSArray arrayWithObjects:@"read_stream", @"publish_stream", @"offline_access",nil] retain];
        loginView = [[UIView alloc] initWithFrame:_rect];
    }
    return self;
}

- (void) login:(id)sender {
    [_facebook authorize:_permissions delegate:self];
}

- (void) loadView {
	self.view = [[UIView alloc] initWithFrame:rect];
	self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *loginButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];    
    loginButton.frame = CGRectMake(10.0, 10.0, 100.0, 50.0);
    [loginButton setTitle:@"Login" forState:UIControlStateNormal];
    
    loginButton.backgroundColor = [UIColor clearColor];
    [loginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    UIImage *buttonImageNormal = [UIImage imageNamed:@"LoginNormal.png"];    
    UIImage *strechableButtonImageNormal = [buttonImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];    
    [loginButton setBackgroundImage:strechableButtonImageNormal forState:UIControlStateNormal];
    
    UIImage *buttonImagePressed = [UIImage imageNamed:@"LoginPressed.png"];    
    UIImage *strechableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:12 topCapHeight:0];    
    [loginButton setBackgroundImage:strechableButtonImagePressed forState:UIControlStateHighlighted];
    
    [loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:loginButton];
	//[self.view addSubview:loginView];
}

-(void) viewDidLoad {
    _facebook = [[Facebook alloc] initWithAppId:kAppId];
//	[UIView beginAnimations:nil];
//	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//	[UIView setAnimationDuration:0.50];
//	[self.view addSubview:self.loginView];
//	self.loginView.alpha = 1.0;
//	[UIView endAnimations];
}

- (void) fbDidLogin {
    NSLog(@"LOGGED IN");
//    NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me/feed"];
//    ASIFormDataRequest *newRequest = [ASIFormDataRequest requestWithURL:url];
//    [newRequest setPostValue:@"I'm learning how to post to Facebook from an iPhone app!" forKey:@"message"];
//    [newRequest setPostValue:@"Check out the tutorial!" forKey:@"name"];
//    [newRequest setPostValue:@"This tutorial shows you how to post to Facebook using the new Open Graph API." forKey:@"caption"];
//    [newRequest setPostValue:@"From Ray Wenderlich's blog - an blog about iPhone and iOS development." forKey:@"description"];
//    [newRequest setPostValue:@"http://www.raywenderlich.com" forKey:@"link"];
//    [newRequest setPostValue:link forKey:@"picture"];
//    [newRequest setPostValue:_accessToken forKey:@"access_token"];
//    [newRequest setDidFinishSelector:@selector(postToWallFinished:)];
//    
//    [newRequest setDelegate:self];
//    [newRequest startAsynchronous];
}

- (void) fbDidNotLogin:(BOOL)cancelled {
    NSLog(@"did not login");
}

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"received response");
}

- (void) dealloc {
    [_facebook release];
    [_permissions release];
    [super dealloc];
}

@end