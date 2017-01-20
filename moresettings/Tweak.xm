#include <dlfcn.h>
#import "substrate.h"
#import <Foundation/Foundation.h>

MSHook(void *, dlopen, const char *path, int mode) {
        NSLog(@": dlopen(%s, %i)", path, mode);

        NSString *newPath = [@"/var/theos/sdks/iPhoneOS7.1.sdk" stringByAppendingString:[NSString stringWithUTF8String:path]];
        NSLog(@"librarian: %@", newPath);
        return _dlopen([newPath UTF8String], mode);
}

%ctor {
@autoreleasepool {
	MSHookFunction(dlopen, MSHake(dlopen));
}
}