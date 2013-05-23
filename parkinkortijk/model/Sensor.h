//
//  Sensor.h
//  parkinkortijk
//
//  Created by Martijn Vandenberghe on 23/05/13.
//  Copyright (c) 2013 Martijn Vandenberghe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Sensor : NSObject {
    NSString *straat;
    BOOL vrij;
    int parkingBay;
    int parkingzone;
    CLLocation *locatie;
}

@property (nonatomic, strong) NSString *straat;
@property (nonatomic) BOOL vrij;
@property (nonatomic) int parkingBay;
@property (nonatomic) int parkingZone;
@property (nonatomic, strong) CLLocation *locatie;

- (id)initParkeerplaatsInStraat:(NSString*)straatNaam
                         inZone:(NSString*)zoneNummer
                   metBayNummer:(NSString*)parkingBayNummer
                          opLat:(NSString*)latitude
                         enLong:(NSString*)longitude
                    enMetStatus:(NSString*)statusString;

@end
