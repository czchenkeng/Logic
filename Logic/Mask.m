//
//  Viewport.m
//  Logic
//
//  Created by Pavel Krusek on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Mask.h"


@implementation Mask

#pragma mark Clipping logic

- (void) visit {
	if (!self.visible)
		return;
    
	glPushMatrix();
    
	glEnable(GL_SCISSOR_TEST);
    
    float x;
    float y;
    float width;
    float height;
    
    if( [[CCDirector sharedDirector] enableRetinaDisplay:YES]) {
        x = self.position.x * 2;
        y = self.position.y * 2;
        width = self.contentSize.width * 2;
        height = self.contentSize.height * 2; 
    } else {
        x = self.position.x;
        y = self.position.y;
        width = self.contentSize.width;
        height = self.contentSize.height;
    }
		
    
    glScissor(x, y, width, height);
    
	[super visit];
    
	glDisable(GL_SCISSOR_TEST);
	glPopMatrix();
}


#pragma mark Init & Dealloc

+ (Mask*) maskWithRect:(CGRect)rect {
	return [[[self alloc] initWithRect:rect] autorelease];
}

- (id) initWithRect:(CGRect)r {
	if ((self = [super init])) {
		self.position = r.origin;
		self.contentSize = r.size;
	}
    
	return self;
}

- (void) redrawRect:(CGRect)r {
    self.position = r.origin;
    self.contentSize = r.size;
}

@end
