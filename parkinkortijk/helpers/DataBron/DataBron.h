//
//  DataBron.h
//  parkinkortijk
//
//  Created by Martijn Vandenberghe on 23/05/13.
//  Copyright (c) 2013 Martijn Vandenberghe. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataBron;

@protocol DataBronDelegate <NSObject>

@optional
- (void)dataOpgevraagdVoorAlleSensoren:(NSArray*)sensoren;

@end

@interface DataBron : NSObject <NSXMLParserDelegate> {
    NSMutableArray *sensoren;
}

@property (nonatomic, retain) id<DataBronDelegate>delegate;
@property (nonatomic, retain) NSMutableArray *sensoren;

- (void)haalParkeerDataOp:(id)sender;

@end
