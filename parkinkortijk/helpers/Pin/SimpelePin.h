//
//  SimpelePin.h
//  parkinkortijk
//
//  Created by Martijn Vandenberghe on 23/05/13.
//  Copyright (c) 2013 Martijn Vandenberghe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface SimpelePin : NSObject<MKAnnotation> {
    CLLocationCoordinate2D coordinate;
}

-(id)initMetCoordinaat:(CLLocationCoordinate2D)coordinaat;

@end
