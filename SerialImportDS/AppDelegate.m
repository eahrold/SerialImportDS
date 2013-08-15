//
//  AppDelegate.m
//  SerialImportDS
//
//  Created by Eldon Ahrold on 8/13/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    computerArray = [[NSMutableArray alloc] init];
    _computerCount.stringValue = @"01";
    
    [self getDefaults];

    if(!self.authHeader || !self.serverURL){
        [self showDefaultsPanel];
    }

}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
}

-(void)applicationWillTerminate:(NSNotification *)notification{
    //finalize things
    [self setDefaults];
    if(computerArray.count != 0){
        [self exportForProfileManager];
    }
}


//--------------------------------------------
//  Computer Add Methods
//--------------------------------------------
- (IBAction)addButtonPressed:(id)sender{
    
    Computer* computer = [Computer new];
    [computer setComputerName:_computerName.stringValue withCount:_computerCount.stringValue];
    [computer setSerialNumber:_serialNumber.stringValue];
    
    
    Server* server = [Server new];
    [ server setURL:self.serverURL];
    [ server setBasicHeaders:self.authHeader];
    [ server setServerAddEntryPath:computer.serial];
    

    /*do some sanity checks first*/
    if([computer.name isEqualToString:@""] || [computer.serial isEqualToString:@""]){
        NSLog(@"Oops, there are empty fileds");
        return;
    }
    
    /*then check if we've already entered the computer*/
    for (NSDictionary *check in computerArray) {
        NSString* str = [check valueForKey:@"serial"];

        if ([[_serialNumber.stringValue uppercaseString] isEqualToString:str]){
            NSLog(@"Duplicate Serial");
            return;
        }
    }
    
    /* set up the request data */
    NSMutableDictionary* di = [[NSMutableDictionary alloc] initWithCapacity:3];
    [di setObject:computer.name forKey:@"dstudio-hostname"];
    [di setObject:computer.serial forKey:@"dstudio-host-serial-number"];
    [di setObject:@"dstudio-host-serial-number" forKey:@"dstudio-host-primary-key"];
    
    
    server.requestData = [[di description] dataUsingEncoding:NSUTF8StringEncoding];
    
    [server postRequestWithData];
    
    NSLog(@"adding computer");
    
    if(!server.error)
    {
        [self addNameToTable:computer.name andSerial:computer.serial];
    }else{
        [self showErrorAlert:server.error];
    }
}

-(void)addNameToTable:(NSString*)name andSerial:(NSString*)serial{
    
    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:name, @"name",serial, @"serial", nil];
    
    [computerArray addObject:dict];
    [computerArray sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil]];
    
    [arrayController setContent:computerArray];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumIntegerDigits:2];
    [formatter setMinimumIntegerDigits:2];
    
    NSNumber* count = [NSNumber numberWithInt:[_computerCount.stringValue intValue] +1];
    _computerCount.stringValue = [NSString stringWithFormat:@"%@",[formatter stringFromNumber:count]];
}

//--------------------------------------------
//  Computer Removal Methods
//--------------------------------------------
-(void)removeRowFromTable:(NSInteger)row{
    [computerArray removeObjectAtIndex:row];
    [arrayController setContent:computerArray];

}

-(IBAction)removeButtonPressed:(id)sender{
    NSInteger row = [_addedComputers selectedRow];
    
    if(row < 0){
        NSLog(@"Nothing selected");
        return;
    }
    
    NSDictionary* dict = [computerArray objectAtIndex:row];

    
    Computer* computer = [Computer new];
    computer.serial = [dict objectForKey:@"serial"];
    
    /* set up the Server object */
    Server* server = [Server new];
    [ server setURL: self.serverURL];
    [ server setBasicHeaders:self.authHeader];
    [ server setServerRemoveEntryPath:computer.serial];
    
    /* send the request */
    [ server postRequestWithData];
    
    if(!server.error){
        [self removeRowFromTable:row];
    }else{
        [self showErrorAlert:server.error];
    }
}

//----------------------------------------------------------
//  Profile Manager Export Methods
//----------------------------------------------------------
-(IBAction)importButtonPressed:(id)sender{
    NSLog(@"Importing Computers from DS database");
    Server* server = [[Server alloc]init];
    [ server setURL:self.serverURL];
    [ server setBasicHeaders:self.authHeader];
    [ server setServerGetListPath];
    
    NSDictionary* dict = [[server getRequest]objectForKey:@"computers"];
    
    if(server.error){
        [self customAlert:server.error];
        return;
    }
    
    
    for(NSString *serial in dict){
        NSDictionary *subDict = [dict objectForKey:serial];
        NSString *name = [subDict objectForKey:@"dstudio-hostname"];
    
        if([name rangeOfString:_importMatch.stringValue].location != NSNotFound){
            [computerArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:name, @"name",serial, @"serial", nil]];
        }
    }
    [arrayController setContent:computerArray];
}



-(void)exportForProfileManager{
    NSSavePanel* saveDlg = [NSSavePanel savePanel];
    [saveDlg setNameFieldStringValue:@"ProfileManagerImport"];
    
    NSString* savePath = [NSString stringWithFormat:@"%@/Desktop/",NSHomeDirectory()];
    [saveDlg setDirectoryURL:[NSURL fileURLWithPath:savePath]];
    [saveDlg setAllowedFileTypes:[NSArray arrayWithObject:@"csv"]];
    [saveDlg setMessage:@"Save for Apple Profile Manager Placeholder import"];
    
    NSURL* fileURL;
    
    if ( [saveDlg runModal] == NSOKButton )
    {
        fileURL = [saveDlg URL];
        
        
        [[NSData data] writeToURL:fileURL options:0 error:nil];
        
        NSFileHandle* fh = [NSFileHandle fileHandleForWritingToURL:fileURL error:nil];
        
        NSString* cvsHeader = @"\"DeviceName\",\"SerialNumber\",\"udid\",\"IMEI\",\"MEID\"\n";
        [fh writeData:[ cvsHeader dataUsingEncoding:NSUTF8StringEncoding ]];
        
        for(NSDictionary* d in computerArray){
            NSString* serial = [NSString stringWithFormat:@"\"%@\"",[d objectForKey:@"serial"]];
            NSString* name = [NSString stringWithFormat:@"\"%@\"",[d objectForKey:@"name"]];
            NSString* empty = @"\"\"";
            
            NSString* placeHolder = [NSString stringWithFormat:@"%@,%@,%@,%@,%@\n",name,serial,empty,empty,empty];
            
            [fh writeData:[ placeHolder dataUsingEncoding:NSUTF8StringEncoding ]];
        }
        [fh closeFile];
    }
}

//-------------------------------------------
//  User Defaults
//-------------------------------------------
-(void)setHeaderAuthFromNameAndPath{
    
}
-(void)getDefaults{
    NSUserDefaults *getDefaults = [NSUserDefaults standardUserDefaults];
    self.authHeader             = [getDefaults objectForKey:@"AuthHeader"];
    self.serverURL              = [getDefaults objectForKey:@"ServerURL"];
    _userName.stringValue       = [getDefaults objectForKey:@"UserName"];
    _serverPort.stringValue     = [getDefaults objectForKey:@"ServerPort"];
    _serverName.stringValue     = [getDefaults objectForKey:@"ServerName"];
    _securedSSL.state           = [getDefaults boolForKey:@"SSLSecured"];
}

-(void)setDefaults{
    NSUserDefaults* setDefaults = [NSUserDefaults standardUserDefaults];
    [setDefaults setObject:self.authHeader forKey:@"AuthHeader"];
    [setDefaults setObject:self.serverURL forKey:@"ServerURL"];
    [setDefaults setObject:self.serverPort.stringValue forKey:@"ServerPort"];
    [setDefaults setObject:self.userName.stringValue forKey:@"UserName"];
    [setDefaults setObject:self.serverName.stringValue forKey:@"ServerName"];
    [setDefaults setBool:self.securedSSL.state forKey:@"SSLSecured"];

    
    [setDefaults synchronize];
}

//-------------------------------------------
//  Progress Panel and Alert
//-------------------------------------------

- (void)showErrorAlert:(NSError *)error {
    [[NSAlert alertWithError:error] beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow]
                                               modalDelegate:self
                                              didEndSelector:nil
                                                 contextInfo:nil];
}

-(void)customAlert:(NSError *)error{
    [[NSAlert alertWithMessageText:[error localizedDescription] defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"something went wrong"]
        beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow] modalDelegate:self
                                                                                didEndSelector:nil
                                                                                contextInfo:nil];
}

- (void)showDefaultsPanel{
    /* Display a progress panel as a sheet */
    [NSApp beginSheet:_defaultsPanel
       modalForWindow:_window
        modalDelegate:self
       didEndSelector:nil
          contextInfo:NULL];
}

-(IBAction)callDefaultSheet:(id)sender{
    [self showDefaultsPanel];
}



- (IBAction)okButtonPressed:(id)sender {
    [self.defaultsPanel orderOut:self];
    [NSApp endSheet:self.defaultsPanel returnCode:0];
}


@end


