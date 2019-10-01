#include "Preferences.h"

@implementation CSRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Prefs" target:self];
	}

	return _specifiers;
}

- (void)respring:(id)sender {
    NSTask *t = [[NSTask alloc] init];
    [t setLaunchPath:@"/usr/bin/killall"];
    [t setArguments:[NSArray arrayWithObjects:@"backboardd", nil]];
    [t launch];
}


//HBTwitterCell,HBLinkTableCell
- (void)openGitHub:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/YuigaWada/CallSlicer"]
              options:@{}
    completionHandler:nil];
}
- (void)openTwitter:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/YuigaWada"]
              options:@{}
    completionHandler:nil];
}


@end
