#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>
#import "StockfishSendOutputMv.h"

@class StockfishVariants;

@interface StockfishBridgeMv : NSObject

@property(strong, nonatomic) StockfishVariants *plugin;

- (instancetype)initWithPlugin:(StockfishVariants *)plugin;

- (void) start;
- (void) cmd: (NSString*)command;
- (void) exit;


@end
