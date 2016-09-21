//
//  ViewController.m
//  IOS_Test
//
//  Created by TuLigen on 16/6/23.
//  Copyright (c) 2016年 TuLigen. All rights reserved.
//

#import "ViewController.h"
#include "ios_lib.h"
#import "OcTest.h"
#import "OcTT+OcTest_Test.h"
@interface ViewController ()
{
    IBOutlet UILabel *myLabel;
}
@property (weak, nonatomic) IBOutlet UIButton *_button;
@property (weak, nonatomic) IBOutlet UILabel *label;



@end

@implementation ViewController
- (IBAction)buttonClick:(id)sender {

    _label.backgroundColor = [UIColor whiteColor];
   
    _label.adjustsFontSizeToFitWidth = YES;
    _label.adjustsLetterSpacingToFitWidth = YES;
    
    OcTT *tt = [[OcChild alloc] init];
    [tt display];
    [tt show];
    [tt calc:3 sec:4];
    
    NSString *str =  [NSString stringWithFormat:@"%d",5];
    _label.text = str;
}
- (IBAction)lowerClick:(id)sender {
}
- (IBAction)uppercaseClick:(id)sender {
}

- (void)awakeFromNib
{
    
}

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    NSLog(@"switch view.");
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _label.backgroundColor = [UIColor grayColor];

    // Do any additional setup after loading the view, typically from a nib.
}

- (BOOL) shouldAutomaticallyForwardAppearanceMethods
{
    return NO;// YES;
}

- (BOOL) shouldAutorotate
{
    return NO;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
