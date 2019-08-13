//
//  VideoPlayerView.m
//  hiChat
//
//  Created by Polly polly on 29/12/2018.
//  Copyright © 2018 HiChat Org. All rights reserved.
//

#import "VideoPlayerView.h"

@interface VideoPlayerView ()

@property (nonatomic, strong) AVPlayer          *player;
@property (nonatomic, strong) AVPlayerLayer     *playerLayer;

@property (nonatomic, assign) BOOL              repeat;

@end

@implementation VideoPlayerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    
    return self;
}

- (void)startPlayItemWithUrl:(NSURL *)url repeat:(BOOL)repeat {
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem:item];
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.bounds;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:self.playerLayer];
    
    [self.player play];
    
    self.repeat = repeat;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoDidPlayToEndTime)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
}

- (void)videoDidPlayToEndTime {
    if (self.repeat) {
        [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            [self.player play];
        }];
    }
    else {
        [self.delegate videoPlayerDidFinished:self];
    }
}

- (void)pause {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
    
    [self.player pause];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    self.playerLayer.frame = bounds;
}

- (void)dealloc {
    
}

@end

