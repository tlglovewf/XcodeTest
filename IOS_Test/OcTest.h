//
//  OcTest.h
//  IOS_Test
//
//  Created by TuLigen on 16/9/18.
//  Copyright © 2016年 TuLigen. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface OcTT : NSObject

-(void) display;

-(void) calc:(int) a  sec: (int)b;

@end

@interface OcChild : OcTT

-(void) display;

@property int num;
@end


@protocol MyProtocol <NSObject>






@end