//
//  Sensor.m
//  parkinkortijk
//
//  Created by Martijn Vandenberghe on 23/05/13.
//  Copyright (c) 2013 Martijn Vandenberghe. All rights reserved.
//

#import "Sensor.h"

@implementation Sensor

@synthesize straat, vrij, parkingZone, parkingBay, locatie;

- (id)init {
    if (self = [super init]) {
        self = [self zetStandaardWaardenOp:self];
    }
    return self;
}

- (id)initParkeerplaatsInStraat:(NSString*)straatNaam
                         inZone:(NSString*)zoneNummer
                   metBayNummer:(NSString*)parkingBayNummer
                          opLat:(NSString*)latitude
                         enLong:(NSString*)longitude
                    enMetStatus:(NSString*)statusString {
    if (self = [super init]) {        
        self.straat = straatNaam;
        self.parkingZone = [zoneNummer intValue];
        self.parkingBay = [parkingBayNummer intValue];
        self.locatie = [self maakMooierCoordinaatMetLat:(NSString*)latitude enLong:(NSString*)longitude];
        if ([statusString isEqualToString:@"Free"]) {
            self.vrij = YES;
        }
    }
    
    return self;
}

- (id)zetStandaardWaardenOp:(id)sensor {
    [sensor setStraat:@""];
    [sensor setParkingZone:0];
    [sensor setParkingBay:0];
    [sensor setVrij:NO];
    [sensor setLocatie:[[CLLocation alloc] initWithLatitude:0 longitude:0]];
    
    return sensor;
}

- (CLLocation*)maakMooierCoordinaatMetLat:(NSString*)latitude enLong:(NSString*)longitude {
    //We zeggen welke lelijke tekens we uit deze nog lelijkere strings willen halen
    NSCharacterSet *teFilterenMiserie = [NSCharacterSet characterSetWithCharactersInString:@" '\"N\"O"];
    
    //De gefilterde strings worden objecten in een array.
    //Element 1 = Graden, Element 2 = Minuten, Element 3 = Seconden, de rest is collateral damage
    NSArray *latitudeComponenten = [latitude componentsSeparatedByCharactersInSet:teFilterenMiserie];
    NSArray *longitudeComponenten = [longitude componentsSeparatedByCharactersInSet:teFilterenMiserie];
    
    double latValue = [[latitudeComponenten objectAtIndex:0] doubleValue] +
                        ([[latitudeComponenten objectAtIndex:1] doubleValue] / 60) +
                        ([[latitudeComponenten objectAtIndex:2] doubleValue] / 3600);
    
    double longValue = [[longitudeComponenten objectAtIndex:0] doubleValue] +
                        ([[longitudeComponenten objectAtIndex:1] doubleValue] / 60) +
                        ([[longitudeComponenten objectAtIndex:2] doubleValue] / 3600);
    
    CLLocation *mooieLocatie = [[CLLocation alloc] initWithLatitude:latValue longitude:longValue];
    
    return mooieLocatie;
}

@end
