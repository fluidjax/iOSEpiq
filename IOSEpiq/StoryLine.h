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

@property (readonly) NSString *text;
@property (readonly) NSDate *createDate;
@property (readonly) NSString *forcedWord;
@property (readonly) BOOL messageSentToConversation;
@property (readonly) int  index;

-(NSAttributedString*)attributedText;
-(instancetype)initWithText:(NSString*)text forcedWord:(NSString*)forcedWord index:(int)index;
@end
