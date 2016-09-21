//
//  OcTest.m
//  IOS_Test
//
//  Created by TuLigen on 16/9/18.
//  Copyright © 2016年 TuLigen. All rights reserved.
//
#import "OcTest.h"

typedef NS_ENUM(NSInteger,FeatureType)
{
    eOne,
    eTwo
};

@implementation OcTT


-(void) display
{
    NSLog(@"hello ObjectC .");
}

-(void) calc:(int)a sec:(int)b
{
    NSLog(@"%d",a + b);
}

@end


@implementation OcChild
@synthesize num;
-(void) display
{
    NSLog(@"this is child.%d", num);
}
-(id) init
{
    if( self = [super init])
    {
        num = eOne;
    }
    return self;
}
-(void) dealloc
{
    NSLog(@"destroy Child.");
}
@end
