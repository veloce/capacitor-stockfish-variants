#include <string>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <mach/machine.h>
#import <Capacitor/CAPPlugin.h>
#import <CapacitorStockfishVariants/CapacitorStockfishVariants-Swift.h>
#import "StockfishBridgeMv.h"
#import "StockfishMv.hpp"

@implementation StockfishBridgeMv

- (instancetype)initWithPlugin:(StockfishVariants *)plugin {
    self = [super init];
    if (self) {
        _plugin = plugin;
    }
    return self;
}

- (void) start {
    CapacitorStockfishVariants::init((__bridge void*)self);
}

- (void) cmd: (NSString*)command {
    CapacitorStockfishVariants::cmd(std::string([command UTF8String]));
}

- (void) exit {
    CapacitorStockfishVariants::exit();
}

- (void) sendOutput: (NSString*)output {
    [_plugin sendOutput:output];
}

void StockfishSendOutputMv (void *bridge, const char *output)
{
  [(__bridge id) bridge sendOutput:[NSString stringWithUTF8String:output]];
}

@end

