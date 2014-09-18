//
//  VOKDetectableClickTableView.h
//  XcodeScriptWriter
//
//  Created by Ellen Shapiro (Vokal) on 9/18/14.
//  Copyright (c) 2014 Vokal Interactive. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol VOKMoarTableViewDelegate <NSObject>

- (void)tableView:(NSTableView *)tableView didClickRow:(NSInteger)rowIndex inColumn:(NSInteger)columnIndex;

@end

/**
 * TableView subclass to allow simple detection of what row and column the user clicked in.
 */
@interface VOKDetectableClickTableView : NSTableView

@property (nonatomic, weak) IBOutlet id<VOKMoarTableViewDelegate> moarDelegate;

@end
