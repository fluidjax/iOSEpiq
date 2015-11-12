//
//  CompletedStoryViewController.h
//  IOSEpiq
//
//  Created by Christopher Morris on 12/11/2015.
//  Copyright © 2015 Christopher Morris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QredoVault.h"
#import "Qredo.h"

@interface CompletedStoryViewController : UIViewController

@property(strong) QredoVaultItemMetadata *vaultItemMetadata;
@property(strong) QredoClient *qredoClient;


@end
