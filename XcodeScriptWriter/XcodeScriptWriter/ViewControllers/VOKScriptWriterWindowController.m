//
//  VOKScriptWriterWindowController.m
//  XcodeScriptWriter
//
//  Created by Ellen Shapiro (Vokal) on 9/18/14.
//  Copyright (c) 2014 Vokal Interactive. All rights reserved.
//

#import "VOKScriptWriterWindowController.h"

#import "VOKLocalizedStrings.h"
#import "VOKScriptForFolder.h"
#import "VOKDetectableClickTableView.h"
#import <AudioToolbox/AudioToolbox.h>

typedef NS_ENUM(NSInteger, VOKTableColumns) {
    VOKTableColumnFolderPath,
    VOKTableColumnShouldRecurse,
    VOKTableColumnScriptPath,
    VOKTableColumnCount
};

@interface VOKScriptWriterWindowController () <NSTableViewDelegate, NSTableViewDataSource, VOKMoarTableViewDelegate>
@property (nonatomic, weak) IBOutlet NSTableView *currentWatchesTableView;
@property (nonatomic, weak) IBOutlet NSButton *addButton;
@property (nonatomic, weak) IBOutlet NSButton *deleteButton;
@property (nonatomic, weak) IBOutlet NSTextField *versionTextField;

@property (nonatomic) NSBundle *bundle;

@property (nonatomic, weak) NSTableColumn *folderColumn;
@property (nonatomic, weak) NSTableColumn *scriptColumn;
@property (nonatomic, weak) NSTableColumn *shouldRecurseColumn;

@property (nonatomic) NSMutableArray *scripts;

@property (nonatomic, copy) NSString *lastChangedString;

@end

@implementation VOKScriptWriterWindowController

- (id)initWithBundle:(NSBundle *)bundle andArray:(NSArray *)scripts
{
    if (self = [super initWithWindowNibName:NSStringFromClass([self class])]) {
        _bundle = bundle;
        _scripts = [NSMutableArray arrayWithArray:scripts];
        self.window.title = [VOKLocalizedStrings pluginName];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSString *version = [self.bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.versionTextField.stringValue = [NSString stringWithFormat:@"%@ v%@", [VOKLocalizedStrings pluginName], version];
    
    //Give the columns titles
    self.folderColumn = self.currentWatchesTableView.tableColumns[VOKTableColumnFolderPath];
    [self.folderColumn.headerCell setStringValue:[VOKLocalizedStrings folderPath]];
    self.scriptColumn = self.currentWatchesTableView.tableColumns[VOKTableColumnScriptPath];
    [self.scriptColumn.headerCell setStringValue:[VOKLocalizedStrings scriptPath]];
    self.shouldRecurseColumn = self.currentWatchesTableView.tableColumns[VOKTableColumnShouldRecurse];
    [self.shouldRecurseColumn.headerCell setStringValue:[VOKLocalizedStrings shouldRecurse]];
}

#pragma mark - IBActions

- (IBAction)addItem:(id)sender
{
    VOKScriptForFolder *addScript = [[VOKScriptForFolder alloc] init];
    [self.scripts addObject:addScript];
    [self.delegate addScript:addScript];
    [self.currentWatchesTableView reloadData];
    [self.currentWatchesTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[self.scripts count] - 1] byExtendingSelection:NO];
}

- (IBAction)removeItem:(id)sender
{
    NSInteger removeMe = self.currentWatchesTableView.selectedRow;
    if (removeMe < 0) {
        //Nothing selected.
        AudioServicesPlayAlertSound(kSystemSoundID_UserPreferredAlert);
        return;
    }
    
    VOKScriptForFolder *removeScript = self.scripts[removeMe];
    [self.delegate removeScript:removeScript];
    [self.scripts removeObjectAtIndex:removeMe];
    [self.currentWatchesTableView reloadData];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.scripts count];
}

- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn //SRSLY, alignment?
            row:(NSInteger)row
{
    if (row >= [self.scripts count]) {
        return nil;
    }
    
    VOKScriptForFolder *scriptForFolder = self.scripts[row];
    
    if (tableColumn == self.folderColumn) {
        return scriptForFolder.pathToFolder;
    } else if (tableColumn == self.shouldRecurseColumn) {
        return @(scriptForFolder.shouldRecurse);
    } else {
        return scriptForFolder.pathToScript;
    }
}

- (void)openChooserForRow:(NSInteger)rowIndex inColumn:(NSInteger)columnIndex;
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseFiles:YES];

    switch (columnIndex) {
        case VOKTableColumnFolderPath:
            [panel setCanChooseDirectories:YES];
            break;
        case VOKTableColumnScriptPath:
            [panel setCanChooseDirectories:NO];
            break;
        default:
            break;
    }
        
    NSInteger clicked = [panel runModal];
    if (clicked == NSFileHandlingPanelOKButton) {
        VOKScriptForFolder *scriptForFolder = self.scripts[rowIndex];
        [self.delegate removeScript:scriptForFolder];
        
        //Single select so only one item
        NSURL *url = [[panel URLs] firstObject];
        NSString *path = [url path];
        NSLog(@"Selected path: %@", path);
        switch (columnIndex) {
            case VOKTableColumnFolderPath:
                self.lastChangedString = scriptForFolder.pathToFolder;
                scriptForFolder.pathToFolder = path;
                break;
            case VOKTableColumnScriptPath:
                self.lastChangedString = scriptForFolder.pathToScript;
                scriptForFolder.pathToScript = path;
                break;
            default:
                break;
        }

        self.scripts[rowIndex] = scriptForFolder;
        [self.delegate addScript:scriptForFolder];
        [self.currentWatchesTableView reloadData];
    }
}

#pragma mark - NSTableViewDelegate

- (void)tableView:(NSTableView *)tableView
   setObjectValue:(id)object
   forTableColumn:(NSTableColumn *)tableColumn
              row:(NSInteger)row
{
    if (!object
        || row >= [self.scripts count]) {
        //Bail out - something was editing as it was deleted and it'll crash if we try to edit it. 
        return;
    }
    
    VOKScriptForFolder *scriptForFolder = self.scripts[row];
    
    if ([object isKindOfClass:[NSString class]]) {
        NSString *string = (NSString *)object;
        if ([string isEqualToString:self.lastChangedString]
            || [string length] == 0) {
            //Bad data after change - bail.
            return;
        }
        
        [self.delegate removeScript:scriptForFolder];

        if (tableColumn == self.folderColumn) {
            scriptForFolder.pathToFolder = string;
        } else {
            scriptForFolder.pathToScript = string;
        }
    } else {
        [self.delegate removeScript:scriptForFolder];
        NSNumber *number = (NSNumber *)object;
        scriptForFolder.shouldRecurse = [number boolValue];
    }
    
    [self.delegate addScript:scriptForFolder];
}

#pragma mark - VOKMoarTableViewDelegate

- (void)tableView:(NSTableView *)tableView didClickRow:(NSInteger)rowIndex inColumn:(NSInteger)columnIndex
{
    if (columnIndex != VOKTableColumnShouldRecurse) {
        [self openChooserForRow:rowIndex inColumn:columnIndex];
    }
}

@end
