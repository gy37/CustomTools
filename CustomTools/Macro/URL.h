//
//  URL.h
//  WMYLink
//
//  Created by yuyuyu on 2020/12/14.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#ifndef Network_h
#define Network_h

#define BASE_URL @""
//#define BASE_URL @""
#define COMBINE_STRINGS(A, B) [NSString stringWithFormat:@"%@%@", A, B]
#define CREATE_URL(PATH) COMBINE_STRINGS(BASE_URL, PATH)

#define VIDEO_AUTH_REFRESH CREATE_URL(@"/aliyun/student/video/address/auth/refresh/get")

#define USER_LOGIN CREATE_URL(@"/auth/oauth/token")

//url后面加websocket，否则报错Error Domain=SRWebSocketErrorDomain Code=2133 "Invalid Sec-WebSocket-Accept response"
#define SOCKET_SERVER_URL CREATE_URL(@"/common/liveRoom/websocket")
#define SOCKET_SEND_URL(liveId) COMBINE_STRINGS(@"/formApp/student/accept.", liveId)
#define SOCKET_SUBSCRIBE_URL(channelId) COMBINE_STRINGS(@"/topic/getResponse.", channelId)

#endif /* Network_h */
