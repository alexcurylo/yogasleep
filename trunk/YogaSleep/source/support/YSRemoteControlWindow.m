//
//  YSRemoteControlWindow.h
//
//  Copyright 2011 Trollwerks Inc. All rights reserved.
//

#import "YSRemoteControlWindow.h"
#import "TWNavigationAppDelegate.h"

@implementation YSRemoteControlWindow

- (void)awakeFromNib
{
   [super awakeFromNib];
   
   // Handle Audio Remote Control events (only available under iOS 4)
   if ([[UIApplication sharedApplication] respondsToSelector:@selector(beginReceivingRemoteControlEvents)])
   {
      [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
   }
}

/*
 - (void)sendEvent:(UIEvent *)event
 {
 if (event.type == UIEventTypeRemoteControl) {
 // Handle event
 }
 else
 [super sendEvent:event];
 }
*/

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
	//twlog("UIEventTypeRemoteControl: %d - %d", event.type, event.subtype);
	
	if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause)
   {
		//twlog("UIEventSubtypeRemoteControlTogglePlayPause");
      [TWDataModel() togglePlayPause];
	}
	if (event.subtype == UIEventSubtypeRemoteControlPlay)
   {
		//twlog("UIEventSubtypeRemoteControlPlay");
      [TWDataModel() play:TWDataModel().playingPlaylist];
	}
	if (event.subtype == UIEventSubtypeRemoteControlPause)
   {
		//twlog("UIEventSubtypeRemoteControlPause");
      [TWDataModel() pause:TWDataModel().playingPlaylist];
	}
	if (event.subtype == UIEventSubtypeRemoteControlStop)
   {
		//twlog("UIEventSubtypeRemoteControlStop");
      [TWDataModel() pause:TWDataModel().playingPlaylist];
	}
	if (event.subtype == UIEventSubtypeRemoteControlNextTrack)
   {
		//twlog("UIEventSubtypeRemoteControlNextTrack");
      [TWDataModel() nextTrack];
	}
	if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack)
   {
		//twlog("UIEventSubtypeRemoteControlPreviousTrack");
      [TWDataModel() previousTrack];
	}
}

@end
