//
//  SocketClient.h
//  Chatting
//
//  Created by Yin Celia on 2021/11/12.
//

#ifndef SocketClient_h
#define SocketClient_h
#import <Foundation/Foundation.h>

@interface ChatContentViewModel : NSObject

@property (nonatomic, copy) void(^returnStateInformation)(NSString *stateInformation);
+ (instancetype)shareInstance;
- (BOOL)connectToHost:(NSString *)ip port:(NSNumber *)port;
- (void)disConnect;
- (void)sendMessage:(NSString *)message;

@end


#endif /* SocketClient_h */
