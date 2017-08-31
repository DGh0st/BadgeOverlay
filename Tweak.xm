@interface SBIconBadgeView : UIView
-(void)resetupBadgeView;
@end

@interface SBDarkeningImageView : UIImageView
@end

@interface FBSystemService
+(id)sharedInstance;
-(void)exitAndRelaunch:(BOOL)arg1;
@end

#define kIdentifier @"com.dgh0st.badgeoverlay"
#define kSettingsPath @"/var/mobile/Library/Preferences/com.dgh0st.badgeoverlay.plist"
#define kSettingsChangedNotification (CFStringRef)@"com.dgh0st.badgeoverlay/settingschanged"
#define kRespringNotification (CFStringRef)@"com.dgh0st.badgeoverlay/respring"

static BOOL isEnabled = YES;
static CGFloat badgeOverlayRoundness = 12.5;

static void reloadPrefs() {
	CFPreferencesAppSynchronize((CFStringRef)kIdentifier);

	NSDictionary *prefs = nil;
	if ([NSHomeDirectory() isEqualToString:@"/var/mobile"]) {
		CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
		if (keyList != nil) {
			prefs = (NSDictionary *)CFPreferencesCopyMultiple(keyList, (CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
			if (prefs == nil)
				prefs = [NSDictionary dictionary];
			CFRelease(keyList);
		}
	} else {
		prefs = [NSDictionary dictionaryWithContentsOfFile:kSettingsPath];
	}

	isEnabled = [prefs objectForKey:@"isEnabled"] ? [[prefs objectForKey:@"isEnabled"] boolValue] : YES;
	badgeOverlayRoundness = [prefs objectForKey:@"badgeOverlayRoundness"] ? [[prefs objectForKey:@"badgeOverlayRoundness"] floatValue] : 12.5;
}

static void respringDevice() {
	[[%c(FBSystemService) sharedInstance] exitAndRelaunch:YES];
}

%hook SBIconView
-(CGRect)_frameForAccessoryView {
	if (isEnabled)
		return (CGRect){CGPointMake(0, 0), %orig().size};
	return %orig();
}
%end

%hook SBIconBadgeView
+(id)_textFont {
	if (isEnabled)
		return [UIFont systemFontOfSize:32];
	return %orig();
}

+(CGPoint)_textOffset {
	if (isEnabled)
		return CGPointMake(14, 18);
	return %orig();
}

-(id)init {
	self = %orig();
	if (self != nil && isEnabled) {
		[self resetupBadgeView];
	}
	return self;
}

-(void)layoutSubviews {
	%orig();

	if (isEnabled)
		[self resetupBadgeView];
}

-(CGPoint)accessoryOriginForIconBounds:(CGRect)arg1 {
	if (isEnabled)
		return CGPointMake(0, 0);
	return %orig(arg1);
}

%new
-(void)resetupBadgeView {
	self.frame = CGRectMake(0, 0, 60, 60);

	SBDarkeningImageView *_backgroundView = MSHookIvar<SBDarkeningImageView *>(self, "_backgroundView");
	if (_backgroundView != nil) {
		_backgroundView.frame = CGRectMake(0, 0, 60, 60);
		_backgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.66];
		_backgroundView.layer.cornerRadius = badgeOverlayRoundness;

		for (UIView *view in [_backgroundView subviews])
			if ([view isKindOfClass:%c(SBIconBlurryBackgroundView)])
				view.hidden = YES;
	}

	SBDarkeningImageView *_textView = MSHookIvar<SBDarkeningImageView *>(self, "_textView");
	if (_textView != nil)
		_textView.center = CGPointMake(30, 30);
}
%end

%dtor {
	CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, kSettingsChangedNotification, NULL);
	CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, kRespringNotification, NULL);
}

%ctor {
	reloadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadPrefs, kSettingsChangedNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)respringDevice, kRespringNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}