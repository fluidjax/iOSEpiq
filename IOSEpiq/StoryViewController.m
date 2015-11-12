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
#import "Story.h"
#import "WordList.h"

@interface StoryViewController ()


@property (assign) BOOL canAddNewStoryLine;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong) IBOutlet UITextView* activeField;
@property (weak, nonatomic) IBOutlet UILabel *currentWordLabel;

@end

@implementation StoryViewController

- (IBAction)sendButtonPressed:(id)sender {
    NSString *textEntered = self.activeField.text;
    
    
    if ([textEntered containsString:self.story.currentWord]){
        StoryLine *storyLine = [[StoryLine alloc] initWithText:textEntered forcedWord:self.story.currentWord];
        [self.story addStoryLine:storyLine];
        [self changeToOtherPersonsTurn];
        [self changeToMyTurn];
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




-(void)viewDidLoad{
    [self registerForKeyboardNotifications];
    self.tableView.estimatedRowHeight = 100;
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self changeToMyTurn];
}

-(void)changeToOtherPersonsTurn{
    self.story.myTurn=NO;
    self.currentWordLabel.text = @"Waiting. . . ";
    
    [self.tableView reloadData];
}



-(void)changeToMyTurn{
    self.story.myTurn=YES;
    self.currentWordLabel.text = self.story.currentWord;
    [self.tableView reloadData];    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.story.myTurn==YES){
        return [self.story lineCount]+1;
    }
    return [self.story lineCount];
}


- (UITableViewCell *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    HeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    cell.storyTitleLabel.text = self.story.title;
    return cell;
}





- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==[self.story lineCount] && self.story.myTurn==YES){
        return 100;
    }
    return UITableViewAutomaticDimension;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==[self.story lineCount] && self.story.myTurn==YES){
        //this is an editable story line cell
        IncompleteLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IncompleteStoryLine"];
        return cell;
    }else{
        //this is a completed story line cell
        CompletedLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CompletedStoryLine"];
        StoryLine *storyLine = [self.story storyLineAtIndex:indexPath.row];
        cell.completeTextLabel.attributedText = [storyLine attributedText];
        cell.numberLabel.text =[ NSString stringWithFormat:@"%ld",indexPath.row+1];
        return cell;
    }
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
    NSLog(@"keybaord was show");
    UIScrollView *scrollView = self.tableView;
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.tableView.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.tableView scrollRectToVisible:[self.tableView rectForRowAtIndexPath:[self lastIndexPath]] animated:YES];
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
