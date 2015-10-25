//
//  FollowCommentTableViewController.m
//  DIY
//
//  Created by Alex Hu on 10/25/15.
//  Copyright © 2015 DIY. All rights reserved.
//

#import "FollowCommentTableViewController.h"

@interface FollowCommentTableViewController ()
@property (nonatomic, strong) NSMutableData *responseData;

@end

@implementation FollowCommentTableViewController{
    NSMutableArray *commentsArray;
    NSMutableArray *makersArray;
    NSInteger *count;
    NSData *url;
    NSMutableString *apiUrl;
    
}
- (void)viewDidLoad {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *follow  = [defaults objectForKey:@"follow"];
    [self setTitle:@"Comments"];
    NSString *titleId  = [defaults objectForKey:@"followid"];
    //NSLog(@"response: %d", [titleId intValue]);
    NSString *string = [NSString stringWithFormat:@"%d", [titleId intValue]];
    
    commentsArray = [[NSMutableArray alloc] init];
    makersArray = [[NSMutableArray alloc] init];
    //NSLog(@"viewdidload");
    self.responseData = [NSMutableData data];
    apiUrl = [NSMutableString stringWithCapacity:50];
    [apiUrl appendString:@"http://api.diy.org/makers/"];
    [apiUrl appendString:follow];
    [apiUrl appendString:@"/projects/"];
    [apiUrl appendString: string];
    [apiUrl appendString:@"/comments"];
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:apiUrl]];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self
                action:@selector(refreshView:)
      forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    [super viewDidLoad];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // NSLog(@"didReceiveResponse");
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //NSLog(@"didFailWithError");
    NSLog([NSString stringWithFormat:@"Connection failed: %@", [error description]]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // NSLog(@"connectionDidFinishLoading");
    //NSLog(@"Succeeded! Received %d bytes of data",[self.responseData length]);
    
    // convert to JSON
    NSError *Error = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&Error];
    
    // extract specific value...
    NSArray *responses = [res objectForKey:@"response"];
    
    for (NSDictionary *response in responses) {
        NSArray *comments = [response objectForKey:@"html"];
        [commentsArray addObject:comments];
        NSDictionary *makers = [response objectForKeyedSubscript:@"maker"];
        NSDictionary *avatar = [makers objectForKey:@"avatar"];
        NSDictionary *icon = [avatar objectForKey:@"icon"];
        NSString *url = [icon objectForKey:@"url"];
        [makersArray addObject:url];
        
    }
    [self refreshUI];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [commentsArray count];
}

-(void)refreshView:(UIRefreshControl *)refresh {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    
    [self refreshUI];
    [refresh endRefreshing];
}
-(void)refreshUI{
    [self.tableView reloadData];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell5" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell];
    }
    UILabel *title = (UILabel *)[cell viewWithTag:161];
    UIImageView *user = (UIImageView *) [cell viewWithTag:162];
    // Configure the cell...
    NSURL *nsurl = [NSURL URLWithString:[makersArray objectAtIndex:indexPath.row]];
    // NSLog(@"nsurl %@",makersArray);
    NSData *imageData = [NSData dataWithContentsOfURL:nsurl];
    UIImage *image = [UIImage imageWithData:imageData];
    [user setImage:image];
    NSString *temp=[commentsArray objectAtIndex:indexPath.row];
    title.text = temp;
    //cell.textLabel.text = [titles objectAtIndex:indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *temp= [commentsArray objectAtIndex:indexPath.row];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:temp forKey:@"followcomment"];
    
    
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}


- (IBAction)Back:(id)sender {
    [self performSegueWithIdentifier:@"Back" sender:self];
}
@end
