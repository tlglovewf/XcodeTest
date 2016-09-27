//
//  ViewController.m
//  UITest
//
//  Created by TuLigen on 16/9/26.
//  Copyright © 2016年 TuLigen. All rights reserved.
//

#import "ViewController.h"
#import "DrawViewController.h"
@interface ViewController ()
{
    DrawViewController *subview;
}
@property (strong, nonatomic) IBOutlet UIView *btnPopView;
@property (strong, nonatomic) IBOutlet UIView *btnPopUI;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) popView
{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    subview = [story instantiateViewControllerWithIdentifier:@"subviewcontroller"];
    [subview setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentViewController:subview animated:YES completion:^{
        NSLog(@"finish.");
    }];
}

-(IBAction) popUI
{
    
}
-(void)callback
{
    
}
@end
