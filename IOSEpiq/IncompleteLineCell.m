//
//  IncompleteStoryLine.m
//  IOSEpiq
//
//  Created by Christopher Morris on 11/11/2015.
//  Copyright © 2015 Christopher Morris. All rights reserved.
//

#import "IncompleteLineCell.h"

@implementation IncompleteLineCell


-(void)prepareForReuse{
    self.storyTextView.text = @"Start typing your story here...";
}


@end
