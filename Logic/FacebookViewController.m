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
    
    label = [[UILabel alloc] init]; 
	label.frame = CGRectMake(10, 10, 150, 40);
	label.textAlignment = UITextAlignmentCenter;
	label.text = @"FACEBOOK";
	[self.view addSubview:label]; 
	[label release];
    
	// Initialization code
	textField = [[UITextView alloc] initWithFrame:CGRectMake(10, 35, 250, 80)];
    //textField.borderStyle = UITextBorderStyleRoundedRect;
	//textField.delegate = self;
	//textField.placeholder = @"I wonder if anybody of you is smarter than me? If you think so, try to beat my new career play score xxxxxx in the iPhone&iPad game The Power of Logic! Check it on iTunes App Store.";
    textField.text = @"I wonder if anybody of you is smarter than me? If you think so, try to beat my new career play score xxxxxx in the iPhone&iPad game The Power of Logic! Check it on iTunes App Store.";
	textField.textAlignment = UITextAlignmentLeft;
	[self.view addSubview: textField];
    //[textField becomeFirstResponder];
    [textField release];
    
    
    UIButton *loginButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];    
    loginButton.frame = CGRectMake(10.0, 150.0, 100.0, 50.0);
    [loginButton setTitle:@"Write to wall" forState:UIControlStateNormal];
    
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
    @try {
        _facebook = [[Facebook alloc] initWithAppId:kAppId];        
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
//    @finally {
//        NSLog(@"finally");
//    }
    CCLOG(@"FACEBOOK %@", _facebook);
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