//
//  ViewController.m
//  WordChange
//
//  Created by TuLigen on 16/9/20.
//  Copyright © 2016年 TuLigen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnUpperCase;
@property (weak, nonatomic) IBOutlet UIButton *btnLowerCase;
@property (weak, nonatomic) IBOutlet UITextField *inputTxt;
@property (weak, nonatomic) IBOutlet UILabel *resultTxt;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _btnUpperCase.layer.borderWidth  = 2;
    _btnUpperCase.layer.cornerRadius = 8;
    _btnUpperCase.layer.borderColor  = [UIColor greenColor].CGColor;
    _btnLowerCase.layer.borderWidth = 2;
    _btnLowerCase.layer.cornerRadius = 8;
    _btnLowerCase.layer.borderColor  = [UIColor greenColor].CGColor;
    
    _resultTxt.adjustsFontSizeToFitWidth = YES;
    _resultTxt.text = @"Results";
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)one:(id)sender {
}
- (IBAction)popView:(id)sender {
}
- (IBAction)popUI:(id)sender {
}
- (IBAction)click {
}
- (IBAction)upperClick:(id)sender {
    NSString *original  = _inputTxt.text;
    NSString *uppercase = [original uppercaseString];
    _resultTxt.text = uppercase;
}
- (IBAction)lowerClick:(id)sender {
    NSString *original = _inputTxt.text;
    NSString *lowercase= [original lowercaseString];
    _resultTxt.text = lowercase;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
