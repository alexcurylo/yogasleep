//
//  YSRemoteControlWindow.h
//
//  Copyright 2011 Trollwerks Inc. All rights reserved.
//

@interface YSRemoteControlWindow : UIWindow
{
}

- (void)awakeFromNib;

//- (void)sendEvent:(UIEvent *)event

- (void)remoteControlReceivedWithEvent:(UIEvent *)event;

@end
