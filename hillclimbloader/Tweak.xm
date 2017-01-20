
#define ApS(a, b) [a stringByAppendingString:b]

NSString *pathToThemeBundle;
NSMutableArray *themeFiles;

%hook CDSoundEngine
- (BOOL)loadBuffer:(int)buffer filePath:(id)path { //for the other sounds. path is a sound file, in HCR .caf but you can use any which cocos2d is able to load.
	%log;
	NSString *originalStandarizedStrippedPath = [[path stringByStandardizingPath] stringByDeletingPathExtension];
	NSString *themeStrippedRelativePath; //this must be relative to the bundle identifier folder in your theme!

	for (NSString *themeFilePath in themeFiles) {
		themeStrippedRelativePath = [themeFilePath stringByDeletingPathExtension];
		
		if ([originalStandarizedStrippedPath hasSuffix:themeStrippedRelativePath]) { //works because the themer has to put relative paths in bundle-themes ;)
			path = [pathToThemeBundle stringByAppendingPathComponent:themeFilePath];
		}
	}

	return %orig(buffer, path);
}
%end

%hook CDAudioManager
- (void)playBackgroundMusic:(id)music loop:(BOOL)loop { //for the background loops.
	%log;


	NSString *originalStandarizedStrippedPath = [[music stringByStandardizingPath] stringByDeletingPathExtension];
	NSString *themeStrippedRelativePath; //this must be relative to the bundle identifier folder in your theme!

	for (NSString *themeFilePath in themeFiles) {
		themeStrippedRelativePath = [themeFilePath stringByDeletingPathExtension];
		
		if ([originalStandarizedStrippedPath hasSuffix:themeStrippedRelativePath]) { //works because the themer has to put relative paths in bundle-themes ;)
			music = [pathToThemeBundle stringByAppendingPathComponent:themeFilePath];
		}
	}

	%orig(music, loop);
}
%end

%ctor {
	themeFiles = [[NSMutableArray alloc] init];

	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/org.h6nry.hclpreferences.plist"];
	NSString *nameOfTheme = [prefs objectForKey:@"theme"];
	NSString *pathToTheme = ApS(@"/Library/Themes/", ApS(nameOfTheme, @".theme/"));
	pathToThemeBundle = ApS(pathToTheme, ApS(@"Bundles/", [[NSBundle mainBundle] bundleIdentifier]));
	//NSLog(@"----------------%@          %@             %@", pathToThemeBundle, nameOfTheme, pathToTheme);

	if ([[NSFileManager defaultManager] fileExistsAtPath:pathToThemeBundle]) {
		//NSLog(@"HCL: there is a bundle named com.f.hcl in your theme!");

		NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:pathToThemeBundle];
	 
		NSString *file;
		while ((file = [dirEnum nextObject])) {
			//NSString *themeableFile = [pathToThemeBundle stringByAppendingPathComponent:file] //[[pathToThemeBundle stringByAppendingPathComponent:file] stringByDeletingPathExtension];
			//NSLog(@"HCL: Found a file which is themeable: %@", file);
			[themeFiles addObject:file];
		}
	}
}