//
//  StoryLine.h
//  IOSEpiq
//
//  Created by Christopher Morris on 11/11/2015.
//  Copyright © 2015 Christopher Morris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface StoryLine : NSObject

@property (strong) NSString *text;
@property (strong) NSDate *createDate;
@property (strong) NSString *forcedWord;
@property (assign) BOOL messageSentToConversation;
@property (assign) int index;

-(NSAttributedString*)attributedText;
-(instancetype)initWithText:(NSString*)text forcedWord:(NSString*)forcedWord index:(int)index;
@end
