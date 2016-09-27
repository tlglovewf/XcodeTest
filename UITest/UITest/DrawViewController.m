//
//  SubViewController.m
//  UITest
//
//  Created by TuLigen on 16/9/26.
//  Copyright © 2016年 TuLigen. All rights reserved.
//

#import "DrawViewController.h"
#import "CanVas.h"
@interface DrawViewController()
@property (weak, nonatomic) IBOutlet UIButton *btnTest;

@end
@implementation DrawViewController
- (IBAction)test:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"back .");
    }];
}

-(void)viewDidLoad
{
//    self.view = [[CanVas alloc] init];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
   CGPoint pt = [[[touches allObjects] objectAtIndex:0] locationInView:self.view];
    NSLog([NSString stringWithFormat:@"begin is %f - %f",pt.x ,pt.y ]);
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint pt = [[[touches allObjects] objectAtIndex:0] locationInView:self.view];
    NSLog([NSString stringWithFormat:@"moving is %f - %f",pt.x ,pt.y ]);
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog([NSString stringWithFormat:@"end is %lu",event.allTouches.count]);
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog([NSString stringWithFormat:@"cancel is %lu",event.allTouches.count]);
}
@end

@implementation DrawViewController(DRAWING)

@end
