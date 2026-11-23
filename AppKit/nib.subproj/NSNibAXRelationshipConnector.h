#import <AppKit/NSNibConnector.h>

@interface NSNibAXRelationshipConnector : NSNibConnector {
}

@end

/*
 * Sets one accessibility attribute of an object when a nib is loaded.  The
 * archive keys are the ones Interface Builder writes.
 */
@interface NSNibAXAttributeConnector : NSObject <NSCoding> {
    id _destination;
    NSString *_attributeType;
    id _attributeValue;
}

- destination;
- (void) setDestination: destination;
- (NSString *) attributeType;
- (void) setAttributeType: (NSString *) type;
- attributeValue;
- (void) setAttributeValue: value;

- (void) replaceObject: original withObject: replacement;
- (void) establishConnection;

@end
