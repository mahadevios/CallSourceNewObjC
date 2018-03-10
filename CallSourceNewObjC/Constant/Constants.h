//
//  Constants.h
//  Communicator
//
//  Created by mac on 23/04/16.
//  Copyright © 2016 Xanadutec. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

//http://localhost:9090/coreflex/
//http://115.249.195.23:8080/Xanadu_MT/

//#define  BASE_URL_PATH                  @"http://192.168.0.13:8080/coreflex/feedcom"
//#define  BASE_URL_PATH                  @"http://115.249.195.23:8080/Xanadu_MT/feedcom"
//#define  BASE_URL_PATH                  @"http://192.168.3.80:9090/coreflex/feedcom"   //sable

//#define  BASE_URL_PATH      @"http://192.168.0.13:7070/coreflex/feedcom"                       //kuldeep

//#define  BASE_URL_PATH                  @"http://192.168.3.75:9091/coreflex/feedcom"//   local

//#define HTTP_UPLOAD_PATH                @"http://localhost:9090/coreflex/resources/CfsFiles/"
//#define HTTP_UPLOAD_PATH                @"http://115.249.195.23:8080/Xanadu_MT/resources/CfsFiles/"
//http://115.249.195.23:8080/Communicator
//#define  BASE_URL_PATH                  @"http://115.249.195.23:8080/Communicator/feedcom"  //live server
//#define  BASE_URL_PATH                  @"http://115.249.195.23:9090/Communicator/feedcom/"  //live server

#define  BASE_URL_PATH                  @"http://192.168.3.75:7777/coreflex/feedcom"
//#define  BASE_URL_PATH                  @"https://callsourcecommunicator.com:8080/coreflex/feedcom"

//#define  BASE_URL_PATH                  @"http://192.168.3.165:8080/coreflex/feedcom"
//#define  BASE_URL_PATH                  @"http://192.168.3.74:9090/coreflex/feedcom"
//#define  BASE_URL_PATH                    @"http://184.171.162.251:8080/Call_Source_Dev/feedcom" // live callsource
//#define HTTP_UPLOAD_PATH                @"http://192.168.3.170:8080/coreflex/resources/CfsFiles/"  //nikhil sir server

#define FTPHostName                     @"@pantudantukids.com"
#define FTPFilesFolderName              @"/TEST/"
#define FTPUsername                     @"demoFtp%40pantudantukids.com"
#define FTPPassword                     @"asdf123"

#define  POST                           @"POST"
#define  GET                            @"GET"
#define  PUT                            @"PUT"
#define  REQUEST_PARAMETER              @"requestParameter"
#define  SUCCESS                        @"1000"
#define  FAILURE                        @"1001"
#define DATE_TIME_FORMAT                       @"yyyy-MM-dd HH:mm:ss"
#define  SDP_MID                        @"sdp_mid"
#define  SDP_MLINE_INDEX                @"sdp_mline_index"
#define  CANDIDATE_SDP                  @"candidate_sdp"
#define  USERDEFAULT_USER               @"userdefaultuser"

// API List
//#define  USER_LOGIN_API                @"getListOfFeedcomAndQueryComForCommunication"
#define NEW_USER_LOGIN_API                  @"login"
#define UPDATE_DEVICE_TOKEN_API             @"MahadevUpdateDeviceToken"
#define SEND_SDP_API                        @"MahadevSendNotificationWithSDP"
#define SEND_CANDIDATES_API                 @"MahadevSendNotificationWithCandidate"
#define GET_LISTOF_REGISTERED_USER          @"getListOfRegisteredUsers"

//#define XIR_GETICE_API @"https://Mahadev:03413bb8-17d0-11e8-8fe5-86a3da8ef5ab@global.xirsys.net/_turn/MyFirstApp"
#define XIR_GET_CRED_API @"https://Mahadev:04effcc2-17e1-11e8-a178-e7f8b0f95b40@global.xirsys.net/_turn/MyFirstApp?expire=1000"


//https://testaccount:092ad88c-e96d-11e6-8a3b-b0db56058b9f@ws.xirsys.com/_turn/channelpath
//getListOfFeedcomForCommunication

//NSNOTIFICATION

//at login web services constants
#define NOTIFICATION_UPDATE_DEVICE_TOKEN            @"uodateDeviceToken"
#define NOTIFICATION_GET_SDP                        @"getSDP"
#define NOTIFICATION_GET_CANDIDATES                 @"getCandidates"
#define NOTIFICATION_GET_LISTOF_REGISTERED_USER     @"getListOfRegisteredUsers"
#define NOTIFICATION_RTC_COONECTION_CHANGED         @"connectionChanged"

#define NOTIFICATION_GOT_TURN                        @"gotTurn"


#endif /* Constants_h */
