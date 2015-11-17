//
//  StoryViewController.h
//  IOSEpiq
//
//  Created by Christopher Morris on 11/11/2015.
//  Copyright © 2015 Christopher Morris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Story.h"

@class Story;
@class WordList;

@interface StoryViewController : UIViewController <UITextViewDelegate, StoryProtocol>
@property (strong) Story *story;

@end
