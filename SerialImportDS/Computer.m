//
//  Computer.m
//  SerialImportDS
//
//  Created by Eldon Ahrold on 8/14/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "Computer.h"

@implementation Computer

-(void)setSerialNumber:(NSString*)serial{
    self.serial = [serial uppercaseString];
}

-(void)setComputerName:(NSString*)name{
    self.name = [name lowercaseString];
}

-(void)setComputerName:(NSString*)name withCount:(NSString*)number{
    self.name = [[NSString stringWithFormat:@"%@-%@",name,number]lowercaseString];
}

@end
