//
//  SimpelePin.m
//  parkinkortijk
//
//  Created by Martijn Vandenberghe on 23/05/13.
//  Copyright (c) 2013 Martijn Vandenberghe. All rights reserved.
//

#import "SimpelePin.h"

@implementation SimpelePin
@synthesize coordinate;

- (NSString *)subtitle{
	return nil;
}

- (NSString *)title{
	return nil;
}

-(id)initMetCoordinaat:(CLLocationCoordinate2D)coordinaat{
	coordinate=coordinaat;
	return self;
}

@end
