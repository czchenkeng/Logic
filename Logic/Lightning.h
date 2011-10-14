//
//  Lightning.h
//  Trundle
//
//  Created by Robert Blackwood on 12/1/09.
//  Copyright 2009 Mobile Bros. All rights reserved.
//

#import "cocos2d.h"
#import "Utils.h"

/*! This will draw lighting and return the midpoint */
CGPoint drawLightning(CGPoint pt1, CGPoint pt2, int displace, int minDisplace, unsigned long randSeed);

@interface Lightning : CCNode<CCRGBAProtocol>
{
	CGPoint _strikePoint;
	CGPoint _strikePoint2;
	
	ccColor3B	_color;
	GLubyte		_opacity;
	BOOL		_split;
	
	int _displacement;
	int _minDisplacement;
	
	unsigned long _seed;
}

@property (readwrite, assign) CGPoint strikePoint;
@property (readwrite, assign) CGPoint strikePoint2;
@property (readwrite, assign) ccColor3B color;
@property (readwrite, assign) GLubyte opacity;
@property (readwrite, assign) BOOL split;
@property (readwrite, assign) int displacement;
@property (readwrite, assign) int minDisplacement;
@property (readwrite, assign) unsigned long seed;

+(id) lightningWithStrikePoint:(CGPoint)strikePoint;
+(id) lightningWithStrikePoint:(CGPoint)strikePoint strikePoint2:(CGPoint)strikePoint2;

-(id) initWithStrikePoint:(CGPoint)strikePoint;
-(id) initWithStrikePoint:(CGPoint)strikePoint strikePoint2:(CGPoint)strikePoint2;

-(void) strikeRandom;
-(void) strikeWithSeed:(unsigned long)seed;
-(void) strike;

@end

@interface Tesla : Lightning
{
	CCNode *_node;
}

+(id) teslaWithNode:(CCNode*)node;
-(id) initWithNode:(CCNode*)node;

@end

