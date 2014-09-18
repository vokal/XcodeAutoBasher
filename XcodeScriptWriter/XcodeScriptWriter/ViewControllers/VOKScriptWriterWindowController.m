//
//  VOKScriptWriterWindowController.m
//  XcodeScriptWriter
//
//  Created by Ellen Shapiro (Vokal) on 9/18/14.
//  Copyright (c) 2014 Vokal Interactive. All rights reserved.
//

#import "VOKScriptWriterWindowController.h"

#import "NSString+Localized.h"
#import "VOKScriptForFolder.h"

typedef NS_ENUM(NSInteger, VOKTableColumns) {
    VOKTableColumnFolderPath,
    VOKTableColumnScriptPath,
    VOKTableColumnCount
};

@interface VOKScriptWriterWindowController () <NSTableViewDelegate, NSTableViewDataSource>
@property (nonatomic, weak) IBOutlet NSTableView *currentWatchesTableView;
@property (nonatomic, weak) IBOutlet NSButton *addButton;
@property (nonatomic, weak) IBOutlet NSButton *deleteButton;
@property (nonatomic, weak) IBOutlet NSTextField *versionTextField;

@property (nonatomic) NSBundle *bundle;

@property (nonatomic, weak) NSTableColumn *folderColumn;
@property (nonatomic, weak) NSTableColumn *scriptColumn;

@property (nonatomic) NSMutableArray *scripts;

@end

@implementation VOKScriptWriterWindowController

- (id)initWithBundle:(NSBundle *)bundle andArray:(NSArray *)scripts
{
    if (self = [super initWithWindowNibName:NSStringFromClass([self class])]) {
        _bundle = bundle;
        _scripts = [NSMutableArray arrayWithArray:scripts];
        self.window.title = [NSString vok_pluginName];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSString *version = [self.bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.versionTextField.stringValue = [NSString stringWithFormat:@"%@ v%@", [NSString vok_pluginName], version];
    
    //Give the columns titles
    self.folderColumn = self.currentWatchesTableView.tableColumns[VOKTableColumnFolderPath];
    [self.folderColumn.headerCell setStringValue:[NSString vok_folderPath]];
    self.scriptColumn = self.currentWatchesTableView.tableColumns[VOKTableColumnScriptPath];
    [self.scriptColumn.headerCell setStringValue:[NSString vok_scriptPath]];
}

#pragma mark - IBActions

- (IBAction)addItem:(id)sender
{
    VOKScriptForFolder *addScript = [[VOKScriptForFolder alloc] init];
    [self.scripts addObject:addScript];
    [self.delegate addScript:addScript];
    [self.currentWatchesTableView reloadData];
}

- (IBAction)removeItem:(id)sender
{
    NSInteger removeMe = self.currentWatchesTableView.selectedRow;
    if (removeMe < 0) {
        //Nothing selected.
        [[NSSound soundNamed:@"Funk"] play];
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
    VOKScriptForFolder *scriptForFolder = self.scripts[row];
    
    if (tableColumn == self.folderColumn) {
        return scriptForFolder.pathToFolder;
    } else {
        return scriptForFolder.pathToScript;
    }
}

#pragma mark - NSTableViewDelegate

- (void)tableView:(NSTableView *)tableView
   setObjectValue:(id)object
   forTableColumn:(NSTableColumn *)tableColumn
              row:(NSInteger)row
{
    NSString *string = (NSString *)object;
    VOKScriptForFolder *scriptForFolder = self.scripts[row];
    [self.delegate removeScript:scriptForFolder];
    
    if (tableColumn == self.folderColumn) {
        scriptForFolder.pathToFolder = string;
    } else {
        scriptForFolder.pathToScript = string;
    }
    
    NSLog(@"Script for folder: %@", scriptForFolder);
    
    [self.delegate addScript:scriptForFolder];
}

@end
