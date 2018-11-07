//
//  CalendarTableViewController.m
//  NativeO365CalendarEvents
//
//  Created by Andrew Connell on 11/7/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "CalendarTableViewController.h"
#import "AuthenticationManager.h"
#import <MSAL/MSAL.h>

@interface CalendarTableViewController ()
@property (strong, nonatomic) NSMutableArray* eventsList;
@end

@implementation CalendarTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.eventsList = [[NSMutableArray alloc] init];
    [self getEvents];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)getEvents
{
    // authProvider
    AuthenticationManager *authManager = [AuthenticationManager sharedInstance];
    
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(100,100,50,50)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [spinner setColor:[UIColor blackColor]];
    [self.view addSubview:spinner];
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    
    NSString *dataUrl = @"https://graph.microsoft.com/v1.0/me/events?$select=subject,start,end";
    NSURL *url = [NSURL URLWithString:dataUrl];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json, text/plain, */*" forHTTPHeaderField:@"Accept"];
    
    NSString *authorization = [NSString stringWithFormat:@"Bearer %@", authManager.accessToken];
    [request setValue:authorization forHTTPHeaderField:@"Authorization"];
    
    __weak CalendarTableViewController *weakSelf = self;
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                // ...
                                                CalendarTableViewController *strongSelf = weakSelf;
                                                NSError *jsonError = nil;
                                                
                                                NSDictionary *jsonFinal = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                                                if (jsonError)
                                                {
                                                    NSLog(@"Error: %@", jsonError);
                                                }
                                                self.eventsList = [jsonFinal valueForKey:@"value"];
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [spinner stopAnimating];
                                                    [spinner removeFromSuperview];
                                                    [strongSelf.tableView reloadData];
                                                });
                                            }];
    
    [task resume];
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
-(NSString *)converStringToDateString:(NSString *)stringDate {
    NSString *result = @"";
    
    NSDateFormatter *retdateFormat = [[NSDateFormatter alloc] init];
    [retdateFormat setDateFormat:@"yyyy'/'MM'/'dd HH':'mm"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"];
    NSDate *convertData =[formatter dateFromString:stringDate];
    
    result = [retdateFormat stringFromDate:convertData];
    
    return result;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 300, 200)];
    
    UIButton* actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [actionButton setFrame:CGRectMake(15, 15, 100, 40)];
    [actionButton setBackgroundImage:[self imageWithColor:[UIColor grayColor]] forState:UIControlStateNormal];
    [actionButton setTitle:@"Reload" forState:UIControlStateNormal];
    [actionButton addTarget:self action:@selector(getEvents) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:actionButton];
    
    NSString *lbl1str = @"The events in the last 30 days.";
    UILabel *lbl1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 55, 280, 30)];
    lbl1.text = lbl1str;
    lbl1.textAlignment = NSTextAlignmentLeft;
    lbl1.font = [UIFont systemFontOfSize:16];
    lbl1.textColor = [UIColor colorWithRed:136.00f/255.00f green:136.00f/255.00f blue:136.00f/255.00f alpha:1];
    [view addSubview:lbl1];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"eventCellTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    UILabel *subjectLabel = (UILabel *)[cell viewWithTag:100];
    NSDictionary *calendarItem = [self.eventsList objectAtIndex:indexPath.row];
    subjectLabel.text = [calendarItem valueForKey:@"subject"]; // ((MSGraphEvent *)[self.eventsList objectAtIndex:indexPath.row]).subject;;
    
    NSString *startTime = (NSString *)[[calendarItem valueForKey:@"start"] valueForKey:@"dateTime"];
    NSString *endTime = (NSString *)[[calendarItem valueForKey:@"end"] valueForKey:@"dateTime"];
    
    NSString *startText = [NSString stringWithFormat:@"Start: %@",[self converStringToDateString:startTime]];
    NSString *endText = [NSString stringWithFormat:@"%@",[self converStringToDateString:endTime]];
    
    NSString *eventDatetime = startText;
    eventDatetime = [eventDatetime stringByAppendingString:@" - "];
    eventDatetime = [eventDatetime stringByAppendingString:endText];
    
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:200];
    dateLabel.text = eventDatetime;
    
    return cell;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return [self.eventsList count];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
