//
//  StoryViewController.m
//  IOSEpiq
//
//  Created by Christopher Morris on 11/11/2015.
//  Copyright © 2015 Christopher Morris. All rights reserved.
//

#import "StoryViewController.h"
#import "StoryLine.h"
#import "CompletedLineCell.h"
#import "IncompleteLineCell.h"
#import "HeaderCell.h"

#import "WordList.h"

@interface StoryViewController ()


@property (assign) BOOL canAddNewStoryLine;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong) IBOutlet UITextView* activeField;
@property (weak, nonatomic) IBOutlet UILabel *storyTitle;

@end

@implementation StoryViewController

-(void)storyDidUpdate{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
}


-(void)viewDidLoad{
    self.navigationController.navigationBarHidden=NO;
    [self registerForKeyboardNotifications];
    self.story.delegate = self;
    if (self.story.onePlayerGame==NO)[self.story createOrJoinRendezvous];
    self.tableView.estimatedRowHeight = 100;
    self.navigationItem.title = self.story.title;
    self.navigationItem.leftBarButtonItem = nil;
    
    UIBarButtonItem *endStoryButton = [[UIBarButtonItem alloc] initWithTitle:@"End" style:UIBarButtonItemStylePlain
                                                                     target:self action:@selector(endStory)];
    self.navigationItem.rightBarButtonItem = endStoryButton;
}


-(void)endStory{
    [self.story saveToVault];
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (IBAction)sendButtonPressed:(id)sender {
    NSString *textEntered = self.activeField.text;
    
    if ([textEntered containsString:self.story.currentWord]){
        [self.story addNewStoryLine:textEntered forcedWord:self.story.currentWord];
        [self.tableView reloadData];
        
        if ([self.story onePlayerGame]==YES){
            [self.activeField becomeFirstResponder];
        }
    }else{
        NSString *message = [NSString stringWithFormat:@"The line of your story must\n include the word '%@'",self.story.currentWord];
        
        UIAlertController * missingWordAlert=   [UIAlertController
                                      alertControllerWithTitle:@"Word Missing!"
                                      message:message
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [missingWordAlert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        [missingWordAlert addAction:ok];
        
        [self presentViewController:missingWordAlert animated:YES completion:nil];
        
    }
}










- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    HeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    if ([self.story myTurn]){
        cell.currentWordLabel.text = [NSString stringWithFormat:@"use word: %@",self.story.currentWord];
    }else{
        cell.currentWordLabel.text = @"Waiting for other player...";
    }
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    IncompleteLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IncompleteStoryLine"];
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (![self.story myTurn])return 0;
    return 60;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==[self.story lineCount] && self.story.myTurn==YES){
        return 100;
    }
    return UITableViewAutomaticDimension;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==1){
        return [[UITableViewCell alloc] init];
    }
    
    CompletedLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CompletedStoryLine"];
    cell.completeTextLabel.attributedText = [self.story buildAttributedTextStory];
    return cell;
}



#pragma Handle Keyboard Display/Hide
// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}


// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification{
    UIScrollView *scrollView = self.tableView;
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    CGRect aRect = self.tableView.frame;
    aRect.size.height -= kbSize.height;
    CGRect pos = [self.tableView rectForRowAtIndexPath:[self lastIndexPath]];
    CGRect modPos = CGRectMake(pos.origin.x,pos.origin.y+20, pos.size.width, pos.size.height);
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.tableView scrollRectToVisible:modPos animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification{
    UIScrollView *scrollView = self.tableView;
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}


-(NSIndexPath *)lastIndexPath{
    NSInteger lastSectionIndex = MAX(0, [self.tableView numberOfSections] - 1);
    NSInteger lastRowIndex = MAX(0, [self.tableView numberOfRowsInSection:lastSectionIndex] - 1);
    return [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
}


-(void)textViewDidBeginEditing:(UITextView *)textView{
    self.activeField = textView;
    textView.text = @"";
}


@end
