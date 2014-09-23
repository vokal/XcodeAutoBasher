//
//  VOKDetectableClickTableView.h
//  XcodeScriptWriter
//
//  Created by Ellen Shapiro (Vokal) on 9/18/14.
//  Copyright (c) 2014 Vokal Interactive. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol VOKMoarTableViewDelegate <NSObject>

/**
 *  Called whenever the user clicks within the table view.
 *
 *  @param tableView   The table view which was clicked
 *  @param rowIndex    The index of the row where the click occurred
 *  @param columnIndex The index of the column where the click occurred. 
 */
- (void)tableView:(NSTableView *)tableView didClickRow:(NSInteger)rowIndex inColumn:(NSInteger)columnIndex;

@end

/**
 * TableView subclass to allow simple detection of what row and column the user clicked in.
 */
@interface VOKDetectableClickTableView : NSTableView

/**
 * Delegate for VOKMoarTableViewDelegate-specific calls.
 */
@property (nonatomic, weak) IBOutlet id<VOKMoarTableViewDelegate> moarDelegate;

@end
