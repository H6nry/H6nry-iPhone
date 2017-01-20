//A more convenient NSLog, displays function and line. It is included from the "CFLAG -include" in the makefile
#ifndef IMPORT_DEBUG_H

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif

#define IMPORT_DEBUG_H
#endif
