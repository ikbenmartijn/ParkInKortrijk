//
//  ViewController.h
//  parkinkortijk
//
//  Created by Martijn Vandenberghe on 22/05/13.
//  Copyright (c) 2013 Martijn Vandenberghe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "DataBron.h"

#import "Sensor.h"

#import "SimpelePin.h"

@interface ViewController : UIViewController <DataBronDelegate, UITableViewDataSource, UITableViewDelegate> {
    DataBron *dataBron;
    
    NSArray *sensoren;
    NSMutableArray *vrijeParkeerplaatsen;
}

@property (nonatomic, retain) DataBron *dataBron;

@property (nonatomic, retain) NSArray *sensoren;
@property (nonatomic, retain) NSMutableArray *vrijeParkeerplaatsen;

@end