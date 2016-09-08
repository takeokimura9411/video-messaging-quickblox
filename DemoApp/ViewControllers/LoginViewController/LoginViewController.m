//
//  LoginViewController.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 04.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "LoginViewController.h"
#import "ChatManager.h"
#import "OutgoingCallViewController.h"
#import "QBUUser+IndexAndColor.h"
#import "Settings.h"
#import "SVProgressHUD.h"
#import "UsersDataSource.h"

NSString *const kSettingsCallSegueIdentifier = @"SettingsCallSegue";

const CGFloat kInfoHeaderHeight = 44;

@interface LoginViewController()

@property (weak, nonatomic) IBOutlet UILabel *buildVersionLabel;
@property (strong, nonatomic) Settings *settings;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.buildVersionLabel.text = [self version];
    self.settings = Settings.instance;
    
    self.emailTxt.delegate = self;
    self.pwdTxt.delegate = self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //[UsersDataSource.instance loadUsersWithList:self.settings.listType];
}

#pragma mark - Verison

- (NSString *)version {
    
    NSString *appVersion = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
    NSString *appBuild = NSBundle.mainBundle.infoDictionary[@"CFBundleVersion"];
    NSString *version = [NSString stringWithFormat:@"App: %@(build %@)\nQuickbloxRTC: %@\nWebRTC revision:%@",
                         appVersion, appBuild, QuickbloxWebRTCFrameworkVersion, QuickbloxWebRTCRevision];
    return version;
}

- (IBAction)LoginToQB:(id)sender {
    
    QBUUser *user = [QBUUser new];
    user.email = self.emailTxt.text;
    user.password = self.pwdTxt.text;
    
    NSArray* foo = [user.email componentsSeparatedByString: @"@"];
    NSString* login = [foo objectAtIndex: 0];
    
    user.login = login;
    
    [SVProgressHUD setBackgroundColor:user.color];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Login chat", nil)];
    __weak __typeof(self)weakSelf = self;
    
    [QBRequest usersWithEmails:@[user.email]
                          page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:10]
                  successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                      
                      // Successful response with page information and users array
                      ((QBUUser*)users[0]).password = self.pwdTxt.text;
                      [SVProgressHUD dismiss];
                      [self logInChatWithUser:users[0]];
                      
                  } errorBlock:^(QBResponse *response) {
                      // Handle error
                      [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Login error!", nil)];
                  }];
}

#pragma Login in chat

#define DEBUG_GUI 0

- (void)logInChatWithUser:(QBUUser *)user {
    
#if DEBUG_GUI
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
    [self performSegueWithIdentifier:kSettingsCallSegueIdentifier sender:nil];
    
#else
    
    [SVProgressHUD setBackgroundColor:[UIColor grayColor]];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Login chat", nil)];
    
    __weak __typeof(self)weakSelf = self;
    [[ChatManager instance] logInWithUser:user completion:^(BOOL error) {
        
		if (!error) {
			
			[SVProgressHUD dismiss];
            [weakSelf applyConfiguration];
			//[weakSelf performSegueWithIdentifier:kSettingsCallSegueIdentifier sender:nil];
            
            OutgoingCallViewController *outgoingCallVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OutgoingCallViewController"];
            [self.navigationController pushViewController:outgoingCallVC animated:YES];
            
		}
		else {
			
			[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Login error!", nil)];
		}
	} disconnectedBlock:^{
        
		[SVProgressHUD showWithStatus:NSLocalizedString(@"Chat disconnected. Attempting to reconnect", nil)];
        
	} reconnectedBlock:^{
        
		[SVProgressHUD showSuccessWithStatus:@"Chat reconnected"];
	}];
	
#endif
}

- (void)applyConfiguration {
	
    NSMutableArray *iceServers = [NSMutableArray array];
    
    for (NSString *url in self.settings.stunServers) {
        
        QBRTCICEServer *server = [QBRTCICEServer serverWithURL:url username:@"" password:@""];
        [iceServers addObject:server];
    }
    
    [iceServers addObjectsFromArray:[self quickbloxICE]];
    
    [QBRTCConfig setICEServers:iceServers];
    [QBRTCConfig setMediaStreamConfiguration:self.settings.mediaConfiguration];
    [QBRTCConfig setStatsReportTimeInterval:1.f];
}

- (NSArray *)quickbloxICE {
    
    NSString *password = @"baccb97ba2d92d71e26eb9886da5f1e0";
    NSString *userName = @"quickblox";
    
    QBRTCICEServer * stunServer = [QBRTCICEServer serverWithURL:@"stun:turn.quickblox.com"
            username:@""
            password:@""];
    
    QBRTCICEServer * turnUDPServer = [QBRTCICEServer serverWithURL:@"turn:turn.quickblox.com:3478?transport=udp"
            username:userName
            password:password];
    
    QBRTCICEServer * turnTCPServer = [QBRTCICEServer serverWithURL:@"turn:turn.quickblox.com:3478?transport=tcp"
            username:userName
            password:password];
    
    
    return@[stunServer, turnTCPServer, turnUDPServer];
}

@end
