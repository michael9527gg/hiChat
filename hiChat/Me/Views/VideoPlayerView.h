//
//  VideoPlayerView.h
//  hiChat
//
//  Created by Polly polly on 29/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class VideoPlayerView;

@protocol VideoPlayerDelegate <NSObject>

@optional;

- (void)videoPlayerDidFinished:(VideoPlayerView *)player;

@end

@interface VideoPlayerView : UIView

@property (nonatomic, weak) id<VideoPlayerDelegate>     delegate;

- (void)startPlayItemWithUrl:(NSURL *)url repeat:(BOOL)repeat;

- (void)pause;

@end
