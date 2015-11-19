//
//  StoryLine.m
//  IOSEpiq
//
//  Created by Christopher Morris on 11/11/2015.
//  Copyright © 2015 Christopher Morris. All rights reserved.
//

#import "StoryLine.h"

@interface StoryLine ()
@end


@implementation StoryLine


-(instancetype)initWithText:(NSString*)text forcedWord:(NSString*)forcedWord index:(int)index{
    self = [super init];
    if (self) {
        _forcedWord                 = forcedWord;
        _text                       = text;
        _messageSentToConversation  = NO;
        _index                      = index;
    }
    return self;
}


-(NSAttributedString*)attributedText{
   NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc]initWithString:self.text];
   NSRange searchRange = NSMakeRange(0,self.text.length);
   NSRange foundRange;
   while (searchRange.location < self.text.length) {
       searchRange.length = self.text.length-searchRange.location;
       foundRange = [self.text rangeOfString:self.forcedWord options:NSCaseInsensitiveSearch range:searchRange];
       if (foundRange.location != NSNotFound) {
           searchRange.location = foundRange.location+foundRange.length;
           [attrText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:foundRange];
       } else {
           // no more substring to find
           break;
       }
   }
   return attrText;
}


@end
