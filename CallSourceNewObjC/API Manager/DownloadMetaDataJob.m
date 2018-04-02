//
//  DownloadMetaDataJob.m
//  Communicator
//
//  Created by mac on 05/04/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#import "DownloadMetaDataJob.h"
#include <sys/xattr.h>
#import "AppDelegate.h"
/*================================================================================================================================================*/

@implementation DownloadMetaDataJob
@synthesize downLoadEntityJobName,hud;
@synthesize requestParameter;
@synthesize downLoadResourcePath;
@synthesize downLoadJobDelegate;
@synthesize httpMethod;

@synthesize addTrintsAfterSomeTimeTimer;
@synthesize currentSaveTrintIndex;
@synthesize isNewMatchFound;

-(id) initWithdownLoadEntityJobName:(NSString *) jobName withRequestParameter:(id) localRequestParameter withResourcePath:(NSString *) resourcePath withHttpMethd:(NSString *) httpMethodParameter
{
    self = [super init];
    if (self)
    {
        self.downLoadResourcePath = resourcePath;
        self.requestParameter = localRequestParameter;
        self.downLoadEntityJobName = [[NSString alloc] initWithFormat:@"%@",jobName];
        self.httpMethod=httpMethodParameter;
        
        self.isNewMatchFound = [NSNumber numberWithInt:1];
    }
    return self;
}

/*================================================================================================================================================*/

#pragma mark -
#pragma mark StartMetaDataDownload
#pragma mark -

-(void)startMetaDataDownLoad
{
        //[self sendRequestWithResourcePath:downLoadResourcePath withRequestParameter:requestParameter withJobName:downLoadEntityJobName withMethodType:httpMethod];
    [self sendNewRequestWithResourcePath:downLoadResourcePath withRequestParameter:requestParameter withJobName:downLoadEntityJobName withMethodType:httpMethod];
}



-(void) sendNewRequestWithResourcePath:(NSString *) resourcePath withRequestParameter:(NSDictionary *) dictionary withJobName:(NSString *)jobName withMethodType:(NSString *) httpMethodParameter
{
    responseData = [NSMutableData data];
    
    NSArray *params = [self.requestParameter objectForKey:REQUEST_PARAMETER];
    
  //  NSDictionary *parameterDictionary = dictionary;
    
    NSMutableString *parameter = [[NSMutableString alloc] init];
    for(NSString *strng in params)
    {
        if([[params objectAtIndex:0] isEqualToString:strng]) {
            [parameter appendFormat:@"%@", strng];
        } else {
            [parameter appendFormat:@"&%@", strng];
        }
    }
    
    NSString *webservicePath = [NSString stringWithFormat:@"%@/%@",BASE_URL_PATH,resourcePath];
    
    NSURL *url = [[NSURL alloc] initWithString:[webservicePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    

    request.HTTPBody = [parameter dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:httpMethodParameter];
    
    //[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    // [request setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    
    
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%@",urlConnection);
}

-(void)getICEFromXIR
{
    responseData = [NSMutableData data];
    
    NSString *webservicePath = [NSString stringWithFormat:@"%@",XIR_GET_CRED_API];
    
    NSURL *url = [[NSURL alloc] initWithString:[webservicePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    
    [request setHTTPMethod:PUT];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSString* authStr = @"Mahadev:04effcc2-17e1-11e8-a178-e7f8b0f95b40";
    
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *authValue = [NSString stringWithFormat: @"Basic %@",[authData base64EncodedStringWithOptions:0]];
    
    [request addValue:authValue forHTTPHeaderField:@"Authorization"];
    
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    NSLog(@"%@",urlConnection);
    
}

#pragma mark -
#pragma mark - URL connection callbacks
#pragma mark -

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[responseData setLength:0];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    statusCode = (int)[httpResponse statusCode];
    ////NSLog(@"Status code: %d",statusCode);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    
	[responseData appendData:data];
}


- (NSString *)shortErrorFromError:(NSError *)error
{
   
    return [error localizedDescription];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    ////NSLog(@"Failed %@",error.description);
    ////NSLog(@"%@ Entity Job -",self.downLoadEntityJobName);
    
//    if ([self.downLoadEntityJobName isEqualToString:USER_LOGIN_API])
//    {
////        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
////        [appDelegate hideIndefiniteProgressView];
//        
//        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:[self shortErrorFromError:error] withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
//        
//    }
    [hud hideAnimated:YES];

    if ([self.downLoadEntityJobName isEqualToString:NEW_USER_LOGIN_API])
    {
        //        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        //        [appDelegate hideIndefiniteProgressView];
        [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];
        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:[self shortErrorFromError:error] withCancelText:nil withOkText:@"Ok" withAlertTag:1000];
        
    }
    
   }

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    ////NSLog(@"Success");
    
    //NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:&error];
    
    //NSLog(@"Job Name = %@ Response %@",self.downLoadEntityJobName,response);
    //NSLog(@"%@",response);
    
//    if ([self.downLoadEntityJobName isEqualToString:USER_LOGIN_API])
//    {
//        if (response != nil)
//        {
//            if ([[response objectForKey:@"code"] isEqualToString:SUCCESS])
//            {
//                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_VALIDATE_USER object:response];
//                
//                
//            }else
//            {
//                [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"username or password is incorrect, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
//            }
//        }else
//        {
//            [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
//        }
//    }
 
    
    
    
    if ([self.downLoadEntityJobName isEqualToString:UPDATE_DEVICE_TOKEN_API])
    {
        
        if (response != nil)
        {
            
            if ([[response objectForKey:@"code"] isEqualToString:SUCCESS])
            {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_DEVICE_TOKEN object:response];
                
                [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Message" withMessage:[response valueForKey:@"message"] withCancelText:nil withOkText:@"OK" withAlertTag:1000];
            }
            else
            {
                [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];

                [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error!" withMessage:@"Something went wrong, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
            }
        }else
        {
            [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];
            [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
        }
    }
    
    else
        if ([self.downLoadEntityJobName isEqualToString:XIR_GET_CRED_API])
        {
            
            if (response != nil)
            {
                
                if ([[response objectForKey:@"s"] isEqualToString:@"ok"])
                {
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GOT_TURN object:response];
                    
                    
                }else
                {
                    [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];
                    
                    [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"username or password is incorrect, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
                }
            }else
            {
                [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];
                [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
            }
        }
    
        else
            if ([self.downLoadEntityJobName isEqualToString:GET_LISTOF_REGISTERED_USER])
            {
                
                if (response != nil)
                {
                    
                    if ([[response objectForKey:@"code"] isEqualToString:SUCCESS])
                    {
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GET_LISTOF_REGISTERED_USER object:response];
                        
                        
                    }else
                    {
                        [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];
                        
                        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"username or password is incorrect, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
                    }
                }else
                {
                    [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];
                    [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
                }
            }
            else
                if ([self.downLoadEntityJobName isEqualToString:HANGUP_CALL_API])
                {
                    
                    if (response != nil)
                    {
                        
                        if ([[response objectForKey:@"code"] isEqualToString:SUCCESS])
                        {
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HANG_UP_CALL object:response];
                            
                            
                        }else
                        {
                            [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];
                            
                            [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"username or password is incorrect, please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
                        }
                    }else
                    {
                        [[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];
                        [[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
                    }
                }
//       if ([self.downLoadEntityJobName isEqualToString:UPDATE_DEVICE_TOKEN_API])
//    {
//        
//        if (response != nil)
//        {
//            
//            if ([[response objectForKey:@"code"] isEqualToString:SUCCESS])
//            {
//                
//                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_DEVICE_TOKEN object:response];
//                
//                
//            }else
//            {
//              
//            }
//        }else
//        {
//            //[[[UIApplication sharedApplication].keyWindow viewWithTag:789] removeFromSuperview];
//            //[[AppPreferences sharedAppPreferences] showAlertViewWithTitle:@"Error" withMessage:@"please try again" withCancelText:nil withOkText:@"OK" withAlertTag:1000];
//        }
//    }

   
    
    

}





@end

/*================================================================================================================================================*/
