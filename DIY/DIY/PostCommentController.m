//
//  PostCommentController.m
//  DIY
//
//  Created by Alex Hu on 10/25/15.
//  Copyright © 2015 DIY. All rights reserved.
//

#import "PostCommentController.h"

@interface PostCommentController ()
@property (nonatomic, strong) NSMutableData *responseData;
@end

@implementation PostCommentController
NSMutableString *apiUrl;
- (void)viewDidLoad {
  
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
     NSLog(@"input %@",responses);

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *titleId  = [defaults objectForKey:@"id"];
    //NSLog(@"response: %d", [titleId intValue]);
    NSString *string = [NSString stringWithFormat:@"%d", [titleId intValue]];
    
    self.responseData = [NSMutableData data];
    apiUrl = [NSMutableString stringWithCapacity:50];
    [apiUrl appendString:@"http://api.diy.org/makers/"];
    [apiUrl appendString:@"hiveworking"];
    [apiUrl appendString:@"/projects/"];
    [apiUrl appendString: string];
    [apiUrl appendString:@"/comments"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiUrl]];
   // [[NSURLConnection alloc] initWithRequest:request delegate:self];
    UITextField *input = (UITextField *)[self.view viewWithTag:155];
    NSLog(@"input %@",input.text);
    NSDictionary* jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    input.text,@"raw", nil];
  
    NSError *error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                       options:NSJSONWritingPrettyPrinted error:&error];
      NSLog(@"jsonData %@",jsonData);
    // Specify that it will be a POST request
    request.HTTPMethod = @"POST";
    
    // This is how we set header fields
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"69ca3505e346af373cf3b9d191c6fab216fa5ac4" forHTTPHeaderField:@"x-diy-api-token"];
    
    // Convert your data and set your request's HTTPBody property
    NSString *stringData = input.text;
    [request setHTTPBody:jsonData];
    
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}


@end
