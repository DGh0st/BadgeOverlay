#include "BORootListController.h"
#include <spawn.h>

@implementation BORootListController

- (id)initForContentSize:(CGSize)size {
	self = [super initForContentSize:size];
	if (self != nil) {
		UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon" inBundle:[self bundle] compatibleWithTraitCollection:nil]];
		iconView.contentMode = UIViewContentModeScaleAspectFit;
		iconView.frame = CGRectMake(0, 0, 29, 29);

		[self.navigationItem setTitleView:iconView];
		[iconView release];
	}
	return self;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}
	return _specifiers;
}

- (void)email {
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *emailController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
		[emailController setSubject:@"BadgeOverlay Support"];
		[emailController setToRecipients:[NSArray arrayWithObjects:@"deeppwnage@yahoo.com", nil]];
		[emailController addAttachmentData:[NSData dataWithContentsOfFile:@"/var/mobile/Library/Preferences/com.dgh0st.badgeoverlay.plist"] mimeType:@"application/xml" fileName:@"Prefs.plist"];
		pid_t pid;
		const char *argv[] = { "/usr/bin/dpkg", "-l" ">" "/tmp/dpkgl.log" };
		extern char *const *environ;
		posix_spawn(&pid, argv[0], NULL, NULL, (char *const *)argv, environ);
		waitpid(pid, NULL, 0);
		[emailController addAttachmentData:[NSData dataWithContentsOfFile:@"/tmp/dpkgl.log"] mimeType:@"text/plain" fileName:@"dpkgl.txt"];
		[self.navigationController presentViewController:emailController animated:YES completion:nil];
		[emailController setMailComposeDelegate:self];
		[emailController release];
	}
}

- (void)mailComposeController:(id)controller didFinishWithResult:(MFMailComposeResult)result error:(id)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (void)donate {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/DGhost"]];
}

- (void)follow {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://mobile.twitter.com/D_Gh0st"]];
}

#pragma clang diagnostic pop

- (void)respring {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"BadgeOverlay" message:@"Are you sure you want to respring?" preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction *respringAction = [UIAlertAction actionWithTitle:@"Yes, Respring" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.dgh0st.badgeoverlay/respring"), NULL, NULL, YES);
	}];

	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
		[self dismissViewControllerAnimated:YES completion:nil];
	}];

	[alert addAction:respringAction];
	[alert addAction:cancelAction];

	[self presentViewController:alert animated:YES completion:nil];
}

@end


@implementation BOSliderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)identifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];
	if (self != nil) {
		CGRect frame = [self frame];
		UIButton *alertButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		alertButton.frame = CGRectMake(frame.size.width - 50, 0, 50, frame.size.height);
		alertButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		[alertButton setTitle:@"" forState:UIControlStateNormal];
		[alertButton addTarget:self action:@selector(presentAlert) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:alertButton];
	}
	return self;
}

- (void)presentAlert {
	NSString *rangeString = [NSString stringWithFormat:@"Please enter a value between %.2f and %.2f", [[self.specifier propertyForKey:@"min"] floatValue], [[self.specifier propertyForKey:@"max"] floatValue]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.specifier.name message:rangeString delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Enter", nil];
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	alert.tag = 342879;
	[alert show];

	[[alert textFieldAtIndex:0] setDelegate:self];
	[[alert textFieldAtIndex:0] resignFirstResponder];
	[[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDecimalPad];
	[[alert textFieldAtIndex:0] becomeFirstResponder];
	[alert release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 342879 && buttonIndex == 1) {
		CGFloat value = [[alertView textFieldAtIndex:0].text floatValue];
		[[alertView textFieldAtIndex:0] resignFirstResponder];

		if (value <= [[self.specifier propertyForKey:@"max"] floatValue] && value >= [[self.specifier propertyForKey:@"min"] floatValue]) {
			[self setValue:[NSNumber numberWithFloat:value]];
			[PSRootController setPreferenceValue:[NSNumber numberWithFloat:value] specifier:self.specifier];
		} else {
			UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The value entered is not valid. Try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			errorAlert.tag = 85230234;
			[errorAlert show];
			[errorAlert release];
		}
	} else if (alertView.tag == 85230234) {
		[self presentAlert];
	}
}

@end