//
//  DIYTableViewController.m
//  DIY
//
//  Created by Alex Hu on 10/24/15.
//  Copyright © 2015 DIY. All rights reserved.
//

#import "DIYTableViewController.h"

@interface DIYTableViewController ()
@property (nonatomic, strong) NSMutableData *responseData;

@end

@implementation DIYTableViewController{
    NSMutableArray *titles;
    NSMutableArray *ids;
    NSInteger *count;
    NSMutableArray *urlArray;
    NSMutableString *apiUrl;
    
}
- (void)viewDidLoad {
    
    titles = [[NSMutableArray alloc] init];
    ids = [[NSMutableArray alloc] init];
    urlArray = [[NSMutableArray alloc] init];
    NSLog(@"viewdidload");
    self.responseData = [NSMutableData data];
    apiUrl = [NSMutableString stringWithCapacity:50];
    [apiUrl appendString:@"http://api.diy.org/makers/"];
    [apiUrl appendString:@"hiveworking"];
    [apiUrl appendString:@"/projects"];
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:apiUrl]];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    count = [titles count];
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self
                action:@selector(refreshView:)
      forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    [super viewDidLoad];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog([NSString stringWithFormat:@"Connection failed: %@", [error description]]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[self.responseData length]);
    
    // convert to JSON
    NSError *Error = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&Error];
    
    // extract specific value...
    NSArray *responses = [res objectForKey:@"response"];
    //NSLog(@"response: %@", responses);
    for (NSDictionary *response in responses) {
        NSDictionary *id = [response objectForKey:@"id"];
        [ids addObject:id];
        NSString *title = [response objectForKey:@"title"];
        [titles addObject:title];
        NSDictionary *clips = [response objectForKey:@"clips"];
        
        //NSLog(@"response: %@", clips);
        for (NSDictionary *clip in clips) {
            
            NSDictionary *assets = [clip objectForKey:@"assets"];
            
            NSDictionary *original = [assets objectForKey:@"ios_560"];
            [urlArray addObject:[original objectForKey:@"url"]];
            
            }
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
    
    return [titles count];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell];
    }
    UILabel *title = (UILabel *)[cell viewWithTag:150];
    UIImageView *icon = (UIImage *)[cell viewWithTag:151];
    // Configure the cell...
    NSURL *nsurl = [NSURL URLWithString:[urlArray objectAtIndex:indexPath.row]];
    NSData *imageData = [NSData dataWithContentsOfURL:nsurl];
    UIImage *image = [UIImage imageWithData:imageData];
    [icon setImage:image];
    NSString *temp=[titles objectAtIndex:indexPath.row];
    title.text = @"";
    UILabel *autoformat = [[UILabel alloc] initWithFrame:CGRectMake(110,70+80*indexPath.row, 300, 200)];
    autoformat.numberOfLines = 0;
    autoformat.backgroundColor = [UIColor clearColor];
    autoformat.text =temp;
    [autoformat sizeToFit];
    
    [self.view addSubview:autoformat];
    //cell.textLabel.text = [titles objectAtIndex:indexPath.row];
    return cell;
   
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *temp= [ids objectAtIndex:indexPath.row];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:temp forKey:@"id"];
    NSLog(@"temp: %@", temp);
    
    
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

}


@end
