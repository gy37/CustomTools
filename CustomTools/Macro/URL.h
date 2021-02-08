//
//  URL.h
//  WMYLink
//
//  Created by yizhi on 2020/12/14.
//  Copyright © 2020 YiZhi. All rights reserved.
//

#ifndef Network_h
#define Network_h

#define BASE_URL @""
//#define BASE_URL @""
#define COMBINE_STRINGS(A, B) [NSString stringWithFormat:@"%@%@", A, B]
#define CREATE_URL(PATH) COMBINE_STRINGS(BASE_URL, PATH)

#define LIVE_CHANNEL_CREATE CREATE_URL(@"/live/student/liveChannel/save")
#define LIVE_CHANNEL_CANCEL CREATE_URL(@"/live/student/liveChannel/update/cancel")
#define LIVE_CHANNEL_STATUS CREATE_URL(@"/live/student/liveChannel/get")
#define LIVE_CREATE CREATE_URL(@"/live/student/liveActivity/save")
#define LIVE_UPDATE CREATE_URL(@"/live/student/liveActivity/update")
#define LIVE_CANCEL CREATE_URL(@"/live/student/liveActivity/update/cancel")
//#define LIVE_INFORMATION CREATE_URL(@"/live/student/liveActivity/get")
#define LIVE_ONLINE_NUMBER CREATE_URL(@"/live/student/liveActivity/get/onlineNum")
//#define LIVE_PAUSE CREATE_URL(@"/live/student/liveActivity/pause")
//#define LIVE_RESUME CREATE_URL(@"/live/student/liveActivity/resume")
#define COMMON_LIKE_COUNT CREATE_URL(@"/common/student/commonAdmire/get")
#define COMMON_LIKE_ADD CREATE_URL(@"/common/student/commonAdmire/save")
#define COMMON_LIKE_REDUCE CREATE_URL(@"/common/student/commonAdmire/delete")

#define VIDEO_AUTH CREATE_URL(@"/aliyun/student/video/address/auth/get")
#define VIDEO_AUTH_REFRESH CREATE_URL(@"/aliyun/student/video/address/auth/refresh/get")
//#define VIDEO_INFORMATION CREATE_URL(@"/aliyun/student/video/play/url/get")
#define VIDEO_CLASSIFY_LIST CREATE_URL(@"/video/student/videoClassify/classify/list")
#define VIDEO_CLASSIFY_CHANNEL_LIST CREATE_URL(@"/video/student/videoClassify/channel/by/classify/list")
#define VIDEO_CLASSIFY_CHANNEL_SEARCH CREATE_URL(@"/video/student/videoClassify/interested/channel/list")
#define VIDEO_PUBLISH CREATE_URL(@"/video/student/video/save")
#define IMAGE_AUTH CREATE_URL(@"/aliyun/student/image/address/auth/get")

#define USER_LOGIN CREATE_URL(@"/auth/oauth/token")

//url后面加websocket，否则报错Error Domain=SRWebSocketErrorDomain Code=2133 "Invalid Sec-WebSocket-Accept response"
#define SOCKET_SERVER_URL CREATE_URL(@"/common/liveRoom/websocket")
#define SOCKET_SEND_URL(liveId) COMBINE_STRINGS(@"/formApp/student/accept.", liveId)
#define SOCKET_SUBSCRIBE_URL(channelId) COMBINE_STRINGS(@"/topic/getResponse.", channelId)

#endif /* Network_h */
