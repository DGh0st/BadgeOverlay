@interface SBIconView : UIView
@end

@interface SBIconBadgeView : UIView
-(void)resetupBadgeView;
@end

@interface SBDarkeningImageView : UIImageView
-(void)setImage:(id)arg1;
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
static BOOL isBlackBackgroundEnabled = YES;
static CGFloat badgeOverlayOpacity = 0.66;

static void reloadPrefs() {
	CFPreferencesAppSynchronize((CFStringRef)kIdentifier);

	NSDictionary *prefs = nil;
	if ([NSHomeDirectory() isEqualToString:@"/var/mobile"]) {
		CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
		if (keyList != nil) {
			prefs = (NSDictionary *)CFPreferencesCopyMultiple(keyList, (CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
			if (prefs == nil)
				prefs = [NSDictionary new];
			CFRelease(keyList);
		}
	} else {
		prefs = [[NSDictionary alloc] initWithContentsOfFile:kSettingsPath];
	}

	isEnabled = [prefs objectForKey:@"isEnabled"] ? [[prefs objectForKey:@"isEnabled"] boolValue] : YES;
	badgeOverlayRoundness = [prefs objectForKey:@"badgeOverlayRoundness"] ? [[prefs objectForKey:@"badgeOverlayRoundness"] floatValue] : 12.5;
	isBlackBackgroundEnabled = [prefs objectForKey:@"isBlackBackgroundEnabled"] ? [[prefs objectForKey:@"isBlackBackgroundEnabled"] boolValue] : YES;
	badgeOverlayOpacity = [prefs objectForKey:@"badgeOverlayOpacity"] ? [[prefs objectForKey:@"badgeOverlayOpacity"] floatValue] : 0.66;

	[prefs release];
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

-(void)_updateLabelAccessoryView {
	%orig();

	UIView *_accessoryView = MSHookIvar<UIView *>(self, "_accessoryView");
	if (isEnabled && _accessoryView != nil && [_accessoryView isKindOfClass:%c(SBIconBadgeView)])
		[(SBIconBadgeView *)_accessoryView resetupBadgeView];
}

-(void)_updateAccessoryViewWithAnimation:(BOOL)arg1 {
	%orig(arg1);

	UIView *_accessoryView = MSHookIvar<UIView *>(self, "_accessoryView");
	if (isEnabled && _accessoryView != nil && [_accessoryView isKindOfClass:%c(SBIconBadgeView)])
		[(SBIconBadgeView *)_accessoryView resetupBadgeView];
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
	UIView *parentView = [self superview];

	if (parentView == nil) {
		return;
	} else if ([parentView isKindOfClass:%c(SBIconView)]) {
		CGFloat length = MIN(parentView.bounds.size.width, parentView.bounds.size.height);
		self.frame = CGRectMake(0, 0, length, length);

		SBDarkeningImageView *_backgroundView = MSHookIvar<SBDarkeningImageView *>(self, "_backgroundView");
		if (_backgroundView != nil) {
			_backgroundView.frame = CGRectMake(0, 0, length, length);
			_backgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:badgeOverlayOpacity];
			_backgroundView.layer.cornerRadius = badgeOverlayRoundness;

			if (isBlackBackgroundEnabled)
				[_backgroundView setImage:nil];

			for (UIView *view in [_backgroundView subviews])
				if ([view isKindOfClass:%c(SBIconBlurryBackgroundView)])
					view.hidden = YES;
		}

		SBDarkeningImageView *_textView = MSHookIvar<SBDarkeningImageView *>(self, "_textView");
		if (_textView != nil)
			_textView.center = CGPointMake(length / 2, length / 2);
	} else { // undo our modifications to fix it for force touch menu badges
		SBDarkeningImageView *_backgroundView = MSHookIvar<SBDarkeningImageView *>(self, "_backgroundView");
		SBDarkeningImageView *_textView = MSHookIvar<SBDarkeningImageView *>(self, "_textView");
		if (_backgroundView != nil && _textView != nil) {
			CGRect frame = _textView.frame;
			if (frame.size.height != 0) {
				frame.size.width *= _backgroundView.frame.size.height / frame.size.height;
				frame.size.height = _backgroundView.frame.size.height;
				_textView.frame = frame;
			}

			_textView.center = _backgroundView.center;
		}
	}
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