//
//  Computer.h
//  SerialImportDS
//
//  Created by Eldon Ahrold on 8/14/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Computer : NSObject

@property (copy) NSString *name;
@property (copy) NSString *serial;
@property (copy) NSString *number;
@property (copy) NSString *hostName;
@property (copy) NSString *localHostName;

-(void)setSerialNumber:(NSString*)serial;
-(void)setComputerName:(NSString*)name;
-(void)setComputerName:(NSString*)name withCount:(NSString*)number;

@end
