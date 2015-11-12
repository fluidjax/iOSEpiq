//
//  WordList.h
//  IOSEpiq
//
//  Created by Christopher Morris on 11/11/2015.
//  Copyright © 2015 Christopher Morris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WordList : NSObject


-(instancetype)initWithFilename:(NSString*)filename;
-(NSString*)getRandomWord;
@end
