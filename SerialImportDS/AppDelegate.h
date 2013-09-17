//
//  AppDelegate.h
//  SerialImportDS
//
//  Created by Eldon Ahrold on 8/13/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "Server.h"
#import "Computer.h"
#import "Base64.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>{
    IBOutlet NSArrayController *arrayController;
    NSMutableArray *computerArray;

}

@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSTextField *serialNumber;
@property (assign) IBOutlet NSTextField *computerName;
@property (assign) IBOutlet NSTextField *computerCount;
@property (assign) IBOutlet NSTableView *addedComputers;

@property (assign) IBOutlet NSTextField *importMatch;


@property (copy) NSString* authHeader;
@property (copy) NSString* serverURL;

-(IBAction)addButtonPressed:(id)sender;
-(IBAction)removeButtonPressed:(id)sender;
-(IBAction)importButtonPressed:(id)sender;


//---------------------------------------------------
// Defaults Pannel
//---------------------------------------------------
@property (assign) IBOutlet NSWindow *defaultsPanel;
@property (assign) IBOutlet NSButton *defaultsOKButton;

@property (assign) IBOutlet NSTextField *userName;
@property (assign) IBOutlet NSTextField *passWord;
@property (assign) IBOutlet NSTextField *serverName;
@property (assign) IBOutlet NSTextField *serverPort;
@property (assign) IBOutlet NSButton *securedSSL;

-(IBAction)okButtonPressed:(id)sender;
-(IBAction)callDefaultSheet:(id)sender;



@end
