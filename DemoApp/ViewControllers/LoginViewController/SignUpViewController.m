//
//  SignUpViewController.m
//  sample-videochat-webrtc
//
//  Created by urchin on 12/05/16.
//  Copyright © 2016 QuickBlox Team. All rights reserved.
//

#import "SignUpViewController.h"
#import "SVProgressHUD.h"
#import "LoginViewController.h"

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.emailTxt.delegate = self;
    self.passwordTxt.delegate = self;
    self.fullNameTxt.delegate = self;
}

- (void)viewDidUnload{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)SignUpToQB:(id)sender {
    
    if(![self validateEmailWithString:self.emailTxt.text] || [self.fullNameTxt.text isEqualToString:@""] || [self.fullNameTxt.text isEqualToString:@""]){
        return;
    }
    
    QBUUser *user = [QBUUser user];
    user.fullName = self.fullNameTxt.text;
    user.email = self.emailTxt.text;
    
    NSArray* foo = [user.email componentsSeparatedByString: @"@"];
    NSString* login = [foo objectAtIndex: 0];
    
    user.login = login;
    user.password = self.passwordTxt.text;
    
    
    
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"SignUp...", nil)];
    
    [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
        [SVProgressHUD dismiss];
        
        
        LoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        
        [self.navigationController pushViewController:loginVC animated:YES];
        
        
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        //NSString *error = [NSString stringWithUTF8String:response.error];
        [SVProgressHUD showErrorWithStatus:@"SignUp Error"];
        NSLog(@"error: %@", response.error);
    }];
}

- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

@end
