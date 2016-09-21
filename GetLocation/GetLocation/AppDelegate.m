//
//  AppDelegate.m
//  GetLocation
//
//  Created by TuLigen on 16/9/20.
//  Copyright © 2016年 TuLigen. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
@interface AppDelegate ()<CLLocationManagerDelegate,MKMapViewDelegate>
@property (strong, nonatomic) CLLocationManager *locationMgr;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[ViewController alloc] init];
    [self.window makeKeyAndVisible];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
    button.frame = CGRectMake(0, 100, 100, 30);
    [button setTitle:@"locate" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 320, 20)];
    _label.tag = 101;
    _label.text = @"locate watting...";
    _label.lineBreakMode = UILineBreakModeWordWrap;
    
    _label.layer.borderWidth = 1;
    _label.layer.borderColor = [UIColor greenColor].CGColor;
    _label.textAlignment =  NSTextAlignmentLeft;
    _label.numberOfLines = 0;
    _label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.window addSubview:_label];
    [self.window addSubview:button];
    return YES;
}

-(void)test
{
    _locationMgr = [[CLLocationManager alloc] init];
    
    [_locationMgr setDesiredAccuracy:kCLLocationAccuracyBest];
    [_locationMgr setDistanceFilter:kCLDistanceFilterNone];
    _locationMgr.delegate = self;
    if( [[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
    {
        [_locationMgr requestWhenInUseAuthorization];
        [_locationMgr requestAlwaysAuthorization];
    }
    
    if([CLLocationManager locationServicesEnabled] == NO)
    {
        NSLog(@"No Location Services.");
    }
    [_locationMgr startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didVisit:(CLVisit *)visit
{
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
#if 0
//    NSLog(@"update location.");
    for(CLLocation *location in locations)
    {
//        NSLog(@"--------%@----------",locations);
    }
    CLLocation *currLocation = [locations lastObject];
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    CLLocation *location = [locations objectAtIndex:0];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        for(CLPlacemark *place in placemarks)
        {
            static BOOL bol = FALSE;
            //取出当前位置的坐标
            NSLog(@"latitude : %f,longitude: %f",currLocation.coordinate.latitude,currLocation.coordinate.longitude);
            NSString *str = [NSString stringWithFormat:@"lon:%f-lat:%f",currLocation.coordinate.longitude,currLocation.coordinate.latitude ];
            if(!bol)
            {
                _label.text = str;
                bol = TRUE;
            }
            else
            {
                _label.text  = [NSString stringWithFormat:@"%@\n%@",_label.text,str];
                [_label sizeToFit];
            }
        }
    }];
#else
    if(locations.count > 0)
    {
        static BOOL bol = FALSE;
        CLLocation *location = locations.lastObject;
        NSString *str = [NSString stringWithFormat:@"lon:%f-lat:%f",location.coordinate.longitude,location.coordinate.latitude ];
        if(!bol)
        {
            _label.text = str;
            bol = TRUE;
        }
        else
        {
            _label.text  = [NSString stringWithFormat:@"%@\n%@",_label.text,str];
            [_label sizeToFit];
        }
    }
#endif
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
