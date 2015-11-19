//
//  StoryListTableViewController.m
//  IOSEpiq
//
//  Created by Christopher Morris on 12/11/2015.
//  Copyright © 2015 Christopher Morris. All rights reserved.
//

#import "StoryListTableViewController.h"
#import "QredoVault.h"
#import "CompletedStoryViewController.h"
@interface StoryListTableViewController ()

@property NSMutableArray *storyList;
@end

@implementation StoryListTableViewController



-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=NO;
    self.storyList = [[NSMutableArray alloc] init];
    self.navigationItem.title = @"Completed Stories";
    [self loadStoriesFromVault];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([[segue identifier] isEqualToString:@"StoryListToStoryView"]){
        // Get reference to the destination view controller
        CompletedStoryViewController *completedStoryView = [segue destinationViewController];
        NSIndexPath *selectedIndex = [self.tableView indexPathForCell:sender];
        
        QredoVaultItemMetadata *vaultItemMetadata = [self.storyList objectAtIndex:selectedIndex.row];
        completedStoryView.vaultItemMetadata = vaultItemMetadata;
        completedStoryView.qredoClient = self.qredoClient;
    }
}


-(void)loadStoriesFromVault{
    [self.qredoClient.defaultVault enumerateVaultItemsUsingBlock:^(QredoVaultItemMetadata *vaultItemMetadata, BOOL *stop) {
        [self.storyList addObject:vaultItemMetadata];
    } completionHandler:^(NSError *error) {
        [self.tableView reloadData];
    }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.storyList count];;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    QredoVaultItemMetadata *vaultItemMetadata = [self.storyList objectAtIndex:indexPath.row];
    cell.textLabel.text = vaultItemMetadata.summaryValues[@"StoryTitle"];
    cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


@end
