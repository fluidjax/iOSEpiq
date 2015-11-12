//
//  CompletedStoryViewController.m
//  IOSEpiq
//
//  Created by Christopher Morris on 12/11/2015.
//  Copyright © 2015 Christopher Morris. All rights reserved.
//

#import "CompletedStoryViewController.h"

@interface CompletedStoryViewController ()
@property (weak, nonatomic) IBOutlet UILabel *storyTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation CompletedStoryViewController




-(void)viewDidLoad{
    [super viewDidLoad];
    [self loadVaultItem];
}


-(void)loadVaultItem{
    [self.qredoClient.defaultVault getItemWithDescriptor:self.vaultItemMetadata.descriptor
                                       completionHandler:^(QredoVaultItem *vaultItem, NSError *error) {
                                           if (!error){
                                               [self displayStory:vaultItem];
                                           }else{
                                               NSLog(@"Error retrieving the vault item");
                                           }
                                           
                                       }];
}



-(void)displayStory:(QredoVaultItem *)vaultItem{
    self.storyTextLabel.text = [[NSString alloc] initWithData:vaultItem.value encoding: NSUTF8StringEncoding];
    self.titleLabel.text = vaultItem.metadata.summaryValues[@"StoryTitle"];
}

@end
