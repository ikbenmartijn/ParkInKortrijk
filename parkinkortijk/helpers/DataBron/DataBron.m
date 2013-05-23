//
//  DataBron.m
//  parkinkortijk
//
//  Created by Martijn Vandenberghe on 23/05/13.
//  Copyright (c) 2013 Martijn Vandenberghe. All rights reserved.
//

#import "DataBron.h"

#import "SVHTTPRequest.h"

#import "Sensor.h"

@implementation DataBron

@synthesize sensoren;

- (id)init {
    if (self = [super init]) {
        sensoren = [[NSMutableArray alloc] init];
        [self haalParkeerDataOp:self];
    }
    
    return self;
}

- (void)haalParkeerDataOp:(id)sender {
    //Als er nog data aanwezig is van de vorige load > wissen
    if (sensoren) {
        [sensoren removeAllObjects];
    }
    
    [[SVHTTPClient sharedClient] GET:@"http://www.parkodata.be/OpenData/ShopAndGoOccupation.php"
                          parameters:nil
                          completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
                              NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:response];
                              [xmlParser setDelegate:self];
                              [xmlParser parse];
                          }];
}

- (void)geefDataDoor {
    if ([self.delegate respondsToSelector:@selector(dataOpgevraagdVoorAlleSensoren:)]) {
        [self.delegate dataOpgevraagdVoorAlleSensoren:[NSArray arrayWithArray:sensoren]];
        //[sensoren removeAllObjects];
    }
}

#pragma mark - NSXMLParser Methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"Sensoren"]) {
        //Niks doen, hier ben je voorlopig niks mee
    }
    if ([elementName isEqualToString:@"Sensor"]) {
        //Dit is al interessanter, nieuwe sensor gevonden
        Sensor *nieuweSensor = [[Sensor alloc] initParkeerplaatsInStraat:[attributeDict objectForKey:@"Street"]
                                                                  inZone:[attributeDict objectForKey:@"Zone"]
                                                            metBayNummer:[attributeDict objectForKey:@"Parkingbay"]
                                                                   opLat:[attributeDict objectForKey:@"Lat"]
                                                                  enLong:[attributeDict objectForKey:@"Long"]
                                                             enMetStatus:[attributeDict objectForKey:@"State"]];
        [sensoren addObject:nieuweSensor];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"Sensoren"]) {
        [self geefDataDoor];
    }
}

@end
