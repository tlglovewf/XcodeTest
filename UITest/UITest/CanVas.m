//
//  CanVas.m
//  UITest
//
//  Created by TuLigen on 16/9/26.
//  Copyright © 2016年 TuLigen. All rights reserved.
//

#import "CanVas.h"

@interface Line : NSObject 
{
@public
    CGPoint begin;
    CGPoint end;
}
@end

@implementation Line

@end

@interface CanVas()
{
    CGContextRef context;
}
@property BOOL     drawing;
@property CGPoint  lastPt;
@property CGPoint  newPt;
@property NSMutableArray *lines;
@property Line           *line;
@end

@implementation CanVas


-(void) drawLine
{
   
}

-(id)init
{
    if( self = [super init])
    {
       
    }
    return self;
}

-(void) drawRect:(CGRect)rect
{
    if(nil == _lines)
    {
        _lines = [[NSMutableArray alloc] init];
    }
    context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 2.0);
    
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    for( Line *item in self.lines)
    {
        CGContextMoveToPoint(context   , item->begin.x, item->begin.y);
        CGContextAddLineToPoint(context, item->end.x  , item->end.y  );
        CGContextStrokePath(context);
    }
    
}
@end

@implementation CanVas(Touches)

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.drawing = YES;
    UITouch *touch = [touches anyObject];
    self.lastPt = [touch locationInView:self];
    self.newPt  = [touch locationInView:self];
}


-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    self.newPt     = [touch locationInView:self];
    self.line   = [[Line alloc] init];
    self.line->begin = self.lastPt;
    self.line->end   = self.newPt;
    self.lastPt = self.newPt;
    [_lines addObject:self.line];
    if(self.drawing)
    {
        [self setNeedsDisplay];
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.drawing = NO;
   
//    self.lastPt = CGPointZero;
//    self.newPt  = CGPointZero;
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}
@end