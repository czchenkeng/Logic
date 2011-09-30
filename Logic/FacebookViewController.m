//
//  FacebookViewController.m
//  Logic
//
//  Created by Pavel Krusek on 7/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FacebookViewController.h"

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"

@implementation FacebookViewController
@synthesize facebook = _facebook;
//static NSString *kAppId = @"237730952923005";
static NSString *kAppId = @"279570795404946";


- (id) init {
    self = [super init];
    if (self != nil) {
        _permissions =  [[NSArray arrayWithObjects:@"read_stream", @"publish_stream", @"offline_access",nil] retain];
    }
    return self;
}

- (void) login:(int)score {
    logicScore = score;
    @try {
        _facebook = [[Facebook alloc] initWithAppId:kAppId];        
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    [_facebook authorize:_permissions delegate:self];  
}

//METHODS FOR USER OWN PHOTOS
//- (void)writeToWall {
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"fb_foto" ofType:@"jpg"];
//
//    NSString *message = @"Game logo";
//    
//    NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me/photos"];
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
//    [request addFile:filePath forKey:@"file"];
//    [request setPostValue:message forKey:@"message"];
//    [request setPostValue:_accessToken forKey:@"access_token"];
//    [request setDidFinishSelector:@selector(sendToPhotosFinished:)];
//    
//    [request setDelegate:self];
//    [request startAsynchronous];
//    
//}
//
//- (void)sendToPhotosFinished:(ASIHTTPRequest *)request
//{
//    NSString *responseString = [request responseString];
//    
//    NSMutableDictionary *responseJSON = [responseString JSONValue];
//    NSString *photoId = [responseJSON objectForKey:@"id"];
//    NSLog(@"Photo id is: %@", photoId);
//    
//    NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@?access_token=%@", photoId, [_accessToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    NSURL *url = [NSURL URLWithString:urlString];
//    ASIHTTPRequest *newRequest = [ASIHTTPRequest requestWithURL:url];
//    [newRequest setDidFinishSelector:@selector(getFacebookPhotoFinished:)];
//    
//    [newRequest setDelegate:self];
//    [newRequest startAsynchronous];
//    
//}
//
//- (void)getFacebookPhotoFinished:(ASIHTTPRequest *)request
//{
//    NSString *responseString = [request responseString];
//    NSLog(@"Got Facebook Photo: %@", responseString);
//    
//    NSMutableDictionary *responseJSON = [responseString JSONValue];   
//    
//    NSString *link = [responseJSON objectForKey:@"link"];
//    if (link == nil) return;
//    NSLog(@"Link to photo: %@", link);
//    
//    NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me/feed"];
//    ASIFormDataRequest *newRequest = [ASIFormDataRequest requestWithURL:url];
//    [newRequest setPostValue:@"Message here" forKey:@"message"];
//    [newRequest setPostValue:@"Name here" forKey:@"name"];
//    [newRequest setPostValue:@"Caption here" forKey:@"caption"];
//    [newRequest setPostValue:@"From team" forKey:@"description"];
//    [newRequest setPostValue:@"http://www.google.com" forKey:@"link"];
//    //[newRequest setPostValue:link forKey:@"picture"];
//    [newRequest setPostValue:_accessToken forKey:@"access_token"];
//    [newRequest setDidFinishSelector:@selector(postToWallFinished:)];
//    
//    [newRequest setDelegate:self];
//    [newRequest startAsynchronous];
//    
//}

- (void) writeToWall {
    NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me/feed"];
    ASIFormDataRequest *newRequest = [ASIFormDataRequest requestWithURL:url];
    [newRequest setPostValue:@"" forKey:@"message"];
    [newRequest setPostValue:@"Power of Logic for iPhone&iPad" forKey:@"name"];
    [newRequest setPostValue:@"I wonder if anybody of you is smarter then me?" forKey:@"caption"];
    [newRequest setPostValue:[NSString stringWithFormat:@"If you think so, try to beat my new high score %i in the game Power of Logic! Check it on iTunes App Store.", logicScore] forKey:@"description"];
    [newRequest setPostValue:@"http://itunes.apple.com/us/app/power-of-logic/id452804654" forKey:@"link"];
    [newRequest setPostValue:@"http://www.poweroflogic.net/App_PoL_icon.jpg" forKey:@"picture"];
    //[newRequest setPostValue:@"{name: \"Test another link\", link: \"http://www.apple.com\"" forKey:@"actions"];
    [newRequest setPostValue:_accessToken forKey:@"access_token"];
    [newRequest setDidFinishSelector:@selector(postToWallFinished:)];
    
    [newRequest setDelegate:self];
    [newRequest startAsynchronous];
    
}

- (void) fbDidLogin {
    _accessToken = _facebook.accessToken;
    [self writeToWall];
}

- (void)postToWallFinished:(ASIHTTPRequest *)request
{
    NSString *responseString = [request responseString];
    
    NSMutableDictionary *responseJSON = [responseString JSONValue];
    NSString *postId = [responseJSON objectForKey:@"id"];
    NSLog(@"Post id is: %@", postId);
    
    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Sucessfully posted to wall!" 
												  message:@"Check out your Facebook."
												 delegate:nil 
										cancelButtonTitle:@"OK"
										otherButtonTitles:nil] autorelease];
	[av show];
    
}

- (void) fbDidNotLogin:(BOOL)cancelled {
    NSLog(@"did not login");
    
    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Problems with connection!" 
												  message:@"Check your internet connection and try again."
												 delegate:nil 
										cancelButtonTitle:@"OK"
										otherButtonTitles:nil] autorelease];
	[av show];
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