//
//  LoginViewController.m
//  IOSEpiq
//
//  Created by Christopher Morris on 16/11/2015.
//  Copyright © 2015 Christopher Morris. All rights reserved.
//

#import "LoginViewController.h"
#import "HomeViewController.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *epiqLabelBottomLayoutConstraint;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UISwitch *rememberLoginSwitch;

@end

@implementation LoginViewController



-(void)viewDidLoad{
    [super viewDidLoad];
    [self initializeScreenState];
    if ([self haveLoginValues]){
        [self performSegueWithIdentifier: @"LoginToHome" sender: self];
    }
}


-(void)initializeScreenState{
    NSUserDefaults *userDefs = [NSUserDefaults standardUserDefaults];
    NSString *password = [userDefs objectForKey:@"password"];
    NSString *username = [userDefs objectForKey:@"username"];
    if (password)self.passwordTextField.text = password;
    if (username)self.usernameTextField.text = username;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"LoginToHome"]){
        HomeViewController *homeVC = (HomeViewController*)[segue destinationViewController];
        [homeVC setUsername:self.usernameTextField.text];
        [homeVC setPassword:self.passwordTextField.text];
        
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"FirstRun"]) {
            [[NSUserDefaults standardUserDefaults] setValue:@"1strun" forKey:@"FirstRun"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [homeVC setFirstRun:YES];
        }else{
            [homeVC setFirstRun:NO];
        }
    }
}

-(BOOL)haveLoginValues{
    if (!self.passwordTextField.text || !self.usernameTextField.text)return NO;
    if ([self.passwordTextField.text isEqualToString:@""] || [self.usernameTextField.text isEqualToString:@""])return NO;
    return YES;
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    //remember the current states
    NSUserDefaults *userDefs = [NSUserDefaults standardUserDefaults];
    [userDefs setObject:self.passwordTextField.text forKey:@"password"];
    [userDefs setObject:self.usernameTextField.text forKey:@"username"];
    [userDefs synchronize];
    return YES;
}


@end
