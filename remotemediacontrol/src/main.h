/*
  Just the entry point for everything.
  The job of main is to initialize RCController and to keep the daemon alive. Sounds easy, difficult enough.
*/

// No interface declararions here, except for alive-keeping stub classes.

#import <Foundation/Foundation.h>
#include <syslog.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#import "RCController.h"
