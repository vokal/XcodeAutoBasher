//
//  VOKDetectableClickTableView.m
//  XcodeScriptWriter
//
//  Created by Ellen Shapiro (Vokal) on 9/18/14.
//  Copyright (c) 2014 Vokal Interactive. All rights reserved.
//

#import "VOKDetectableClickTableView.h"

@implementation VOKDetectableClickTableView

- (void)mouseDown:(NSEvent *)theEvent
{
    //Ganked from: http://stackoverflow.com/a/19661253/681493
    NSPoint globalLocation = [theEvent locationInWindow];
    NSPoint localLocation = [self convertPoint:globalLocation fromView:nil];
    NSInteger clickedRow = [self rowAtPoint:localLocation];
    NSInteger clickedColumn = [self columnAtPoint:localLocation];
    
    [super mouseDown:theEvent];
    
    if (clickedRow != -1 && clickedColumn != -1) {
        [self.moarDelegate tableView:self didClickRow:clickedRow inColumn:clickedColumn];
    }
}

@end
