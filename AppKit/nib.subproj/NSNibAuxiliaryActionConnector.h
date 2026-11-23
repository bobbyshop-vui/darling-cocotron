#import <AppKit/NSNibConnector.h>

/*
 * Connects a trigger (e.g. a gesture or key) on the source to an action on the destination.
 * Archive keys: NSSource, NSDestination, NSLabel (from NSNibConnector) and NSTrigger.
 */
@interface NSNibAuxiliaryActionConnector : NSNibConnector {
    id _trigger;
}

- trigger;
- (void) setTrigger: trigger;

@end
