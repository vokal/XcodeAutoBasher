//
//  VOKScriptWriterWindowController.m
//  XcodeScriptWriter
//
//  Created by Ellen Shapiro (Vokal) on 9/18/14.
//  Copyright (c) 2014 Vokal Interactive. All rights reserved.
//

#import "VOKScriptWriterWindowController.h"

#import <AudioToolbox/AudioToolbox.h>

#import "VOKLocalizedStrings.h"
#import "VOKProjectContainer.h"
#import "VOKScriptForFolder.h"

typedef NS_ENUM(NSInteger, VOKTableColumns) {
    VOKTableColumnFolderPath,
    VOKTableColumnShouldRecurse,
    VOKTableColumnScriptPath,
    VOKTableColumnCount
};

@interface VOKScriptWriterWindowController ()

@property (nonatomic, weak) IBOutlet NSTableView *currentWatchesTableView;
@property (nonatomic, weak) IBOutlet NSButton *addButton;
@property (nonatomic, weak) IBOutlet NSButton *deleteButton;
@property (nonatomic, weak) IBOutlet NSTextField *versionTextField;

@property (nonatomic, weak) IBOutlet NSTreeController *treeController;

@property (nonatomic) NSBundle *bundle;

@property (nonatomic, weak) NSTableColumn *folderColumn;
@property (nonatomic, weak) NSTableColumn *scriptColumn;
@property (nonatomic, weak) NSTableColumn *shouldRecurseColumn;

@property (nonatomic, copy) NSString *lastChangedString;

@property (nonatomic, strong) NSArray *selectedIndexPaths;

- (IBAction)selectFolder:(id)sender;
- (IBAction)selectScript:(id)sender;

@end

@implementation VOKScriptWriterWindowController

- (id)initWithBundle:(NSBundle *)bundle
{
    if (self = [super initWithWindowNibName:NSStringFromClass([self class])]) {
        _bundle = bundle;
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

#pragma mark - overridden setters/getters

- (void)setProjects:(NSArray *)projects
{
    _projects = projects;
    NSLog(@"-=> setting self.projects: %@", projects);
    self.selectedIndexPaths = self.selectedIndexPaths;
}

- (void)setSelectedIndexPaths:(NSArray *)selectedIndexPaths
{
    _selectedIndexPaths = selectedIndexPaths;
    VOKProjectScriptFolderTreeObject *selectedObject = [self selectedObject];
    if (selectedObject) {
        [self.addButton setEnabled:YES];
        if ([selectedObject isKindOfClass:[VOKScriptForFolder class]]) {
            [self.deleteButton setEnabled:YES];
        } else {
            [self.deleteButton setEnabled:NO];
        }
    } else {
        // Nothing selected
        [self.deleteButton setEnabled:NO];
        [self.addButton setEnabled:NO];
    }
}

#pragma mark - helpers

- (VOKProjectScriptFolderTreeObject *)selectedObject
{
    NSArray *selectedObjects = self.treeController.selectedObjects;
    if ([selectedObjects count] > 1) {
        NSLog(@"How is more than 1 thing selected??");
    }
    return [selectedObjects firstObject];
}

- (VOKScriptForFolder *)scriptForFolderFromSender:(id)sender
{
    if (![sender isKindOfClass:[NSView class]]) {
        return nil;
    }
    NSView *senderView = sender;
    if ([senderView respondsToSelector:@selector(objectValue)]) {
        id objectValue = [(NSControl *)senderView objectValue];
        if ([objectValue isKindOfClass:[VOKScriptForFolder class]]) {
            return objectValue;
        }
    }
    if (senderView.superview) {
        return [self scriptForFolderFromSender:senderView.superview];
    }
    return nil;
}

- (NSString *)modalChooserWithExistingSelection:(NSString *)existingSelection
                           canChooseDirectories:(BOOL)canChooseDirectories
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseFiles:YES];
    
    [panel setDirectoryURL:[NSURL fileURLWithPath:[existingSelection stringByDeletingLastPathComponent]]];
    [panel setCanChooseDirectories:canChooseDirectories];
    
    NSInteger clicked = [panel runModal];
    if (clicked != NSFileHandlingPanelOKButton) {
        return nil;
    }
    
    // Single select so only one item
    NSURL *url = [[panel URLs] firstObject];
    return [url path];
}

#pragma mark - IBActions

- (IBAction)selectFolder:(id)sender
{
    VOKScriptForFolder *scriptForFolder = [self scriptForFolderFromSender:sender];
    if (!scriptForFolder) {
        return;
    }
    
    NSString *selectedUrl = [self modalChooserWithExistingSelection:scriptForFolder.pathToFolder
                                               canChooseDirectories:YES];
    
    if (selectedUrl) {
        scriptForFolder.pathToFolder = selectedUrl;
    }
}

- (IBAction)selectScript:(id)sender
{
    VOKScriptForFolder *scriptForFolder = [self scriptForFolderFromSender:sender];
    if (!scriptForFolder) {
        return;
    }
    
    NSString *selectedUrl = [self modalChooserWithExistingSelection:scriptForFolder.pathToScript
                                               canChooseDirectories:NO];
    
    if (selectedUrl) {
        scriptForFolder.pathToScript = selectedUrl;
    }
}

- (IBAction)addItem:(id)sender
{
    VOKProjectScriptFolderTreeObject *selectedObject = [self selectedObject];
    if (!selectedObject) {
        // Nothing selected.
        AudioServicesPlayAlertSound(kSystemSoundID_UserPreferredAlert);
        return;
    }
    VOKProjectContainer *project = nil;
    if ([selectedObject isKindOfClass:[VOKProjectContainer class]]) {
        project = (VOKProjectContainer *)selectedObject;
    } else if ([selectedObject respondsToSelector:@selector(containingProject)]) {
        project = [(VOKScriptForFolder *)selectedObject containingProject];
    }
    if (!project) {
        // Need a project to add a script.
        AudioServicesPlayAlertSound(kSystemSoundID_UserPreferredAlert);
        return;
    }
    VOKScriptForFolder *newScriptForFolder = [[VOKScriptForFolder alloc] init];
    [project.topLevelFolderObjects addObject:newScriptForFolder];
    newScriptForFolder.containingProject = project;
    [project save];
    [newScriptForFolder startWatching];
    self.projects = self.projects;
}

- (IBAction)removeItem:(id)sender
{
    VOKProjectScriptFolderTreeObject *selectedObject = [self selectedObject];
    if (!selectedObject) {
        // Nothing selected.
        AudioServicesPlayAlertSound(kSystemSoundID_UserPreferredAlert);
        return;
    }
    if ([selectedObject isKindOfClass:[VOKProjectContainer class]]) {
        // Can't remove a project.
        AudioServicesPlayAlertSound(kSystemSoundID_UserPreferredAlert);
        return;
    }
    VOKScriptForFolder *scriptForFolder = (VOKScriptForFolder *)selectedObject;
    [scriptForFolder remove];
    [self.treeController remove:sender];
}

@end
