#import "LoginViewController.h"
#import "AuthenticationManager.h"
#import <MSAL/MSALUser.h>

NSString * const kAuthority   = @"https://login.microsoftonline.com/common/v2.0";

@interface LoginViewController()
@property (weak, nonatomic) NSArray *scopes;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.activityIndicator.hidden = YES;
}

- (void)showMessage:(NSString*)message withTitle:(NSString *)title {
    UIAlertController * alert= [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                {
                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                    [self showLoadingUI:NO];
                                }];
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showLoadingUI:(BOOL)loading {
    if(loading){
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
        [self.loginButton setTitle:@"Connecting..." forState:UIControlStateNormal];
        self.loginButton.enabled = NO;
    }
    else{
        [self.activityIndicator stopAnimating];
        [self.loginButton setTitle:@"Signin to Microsoft" forState:UIControlStateNormal];
        self.loginButton.enabled = YES;
        self.activityIndicator.hidden = YES;
    }
}

- (IBAction)loginAction:(id)sender{
    [self showLoadingUI:YES];
    
    self.scopes = [NSArray arrayWithObjects:@"https://graph.microsoft.com/User.Read", @"https://graph.microsoft.com/Calendars.Read", nil];
    
    AuthenticationManager *authenticationManager = [AuthenticationManager sharedInstance];
    [authenticationManager initWithAuthority:kAuthority completion:^(NSError *error) {
        if (error) {
            [self showLoadingUI:NO];
            [self showMessage:@"Please see the log for more details" withTitle:@"InitWithAuthority Error"];
        } else {
            [authenticationManager acquireAuthTokenWithScopes:self.scopes completion:^(MSALErrorCode error) {
                if(error){
                    [self showLoadingUI:NO];
                    [self showMessage:@"Please see the log for more details" withTitle:@"AcquireAuthToken Error"];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showLoadingUI:NO];
//                        MSALUser *currentUser = [authenticationManager user];
//
//                        NSString *successMessage = @"Authentication succeeded for: ";
//                        successMessage = [successMessage stringByAppendingString:[currentUser name]];
//                        successMessage = [successMessage stringByAppendingString:@" ("];
//                        successMessage = [successMessage stringByAppendingString:[currentUser displayableId]];
//                        successMessage = [successMessage stringByAppendingString:@")"];
//
//                        [self showMessage:successMessage withTitle:@"Success"];
                        
                        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:NSBundle.mainBundle];
                        UIViewController *calVC = [board instantiateViewControllerWithIdentifier:@"calendarList"];
                        [self.navigationController pushViewController:calVC animated:YES];
                    });
                }
            }];
        }
    }];
}

@end
