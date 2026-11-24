#import <CoreText/CTFontDescriptor.h>
#import <CoreText/CTTypesetter.h>
#import <CoreText/CTLine.h>

#import <Foundation/Foundation.h>

typedef const struct __CTRunDelegate *CTRunDelegateRef;
typedef void (*CTRunDelegateDeallocateCallback)(void *refCon);
typedef CGFloat (*CTRunDelegateMetricCallback)(void *refCon);
typedef struct {
	CFIndex version;
	CTRunDelegateDeallocateCallback dealloc;
	CTRunDelegateMetricCallback getAscent;
	CTRunDelegateMetricCallback getDescent;
	CTRunDelegateMetricCallback getWidth;
} CTRunDelegateCallbacks;

enum { kCTRunDelegateCurrentVersion = 1 };

@interface DarlingLazyRunDelegate : NSObject {
@private
	CTRunDelegateCallbacks _callbacks;
	void *_refCon;
}
- (id)initWithCallbacks:(const CTRunDelegateCallbacks *)callbacks refCon:(void *)refCon;
@end

@implementation DarlingLazyRunDelegate
- (id)initWithCallbacks:(const CTRunDelegateCallbacks *)callbacks refCon:(void *)refCon
{
	self = [super init];
	if (self != nil) {
		_callbacks = *callbacks;
		_refCon = refCon;
	}
	return self;
}

- (void)dealloc
{
	if (_callbacks.dealloc != NULL)
		_callbacks.dealloc(_refCon);
	[super dealloc];
}
@end

CTFontDescriptorRef CTFontDescriptorCreateWithNameAndSize(CFStringRef name, CGFloat size)
{
	if (name == NULL)
		return NULL;

	CFNumberRef fontSize = CFNumberCreate(kCFAllocatorDefault, kCFNumberCGFloatType, &size);
	if (fontSize == NULL)
		return NULL;

	const void *keys[] = { kCTFontNameAttribute, kCTFontSizeAttribute };
	const void *values[] = { name, fontSize };
	CFDictionaryRef descriptor = CFDictionaryCreate(kCFAllocatorDefault, keys, values, 2,
												 &kCFTypeDictionaryKeyCallBacks,
												 &kCFTypeDictionaryValueCallBacks);
	CFRelease(fontSize);
	return (CTFontDescriptorRef) descriptor;
}

CTFontDescriptorRef CTFontDescriptorCreateMatchingFontDescriptor(CTFontDescriptorRef descriptor,
																		 CFDictionaryRef mandatoryAttributes)
{
	(void) descriptor;
	(void) mandatoryAttributes;
	return NULL;
}

CTRunDelegateRef CTRunDelegateCreate(const CTRunDelegateCallbacks *callbacks, void *refCon)
{
	if (callbacks == NULL || callbacks->version != kCTRunDelegateCurrentVersion)
		return NULL;
	DarlingLazyRunDelegate *delegate = [[DarlingLazyRunDelegate alloc]
											initWithCallbacks:callbacks refCon:refCon];
	return (CTRunDelegateRef) delegate;
}

CTLineRef CTTypesetterCreateLineWithOffset(CTTypesetterRef typesetter,
											   CFRange stringRange, double offset)
{
	(void) typesetter;
	(void) stringRange;
	(void) offset;
	return NULL;
}

CTLineRef CTTypesetterCreateLine(CTTypesetterRef typesetter, CFRange stringRange)
{
	(void) typesetter;
	(void) stringRange;
	return NULL;
}

CTTypesetterRef CTTypesetterCreateWithAttributedString(CFAttributedStringRef string)
{
	(void) string;
	return NULL;
}

CFIndex CTTypesetterSuggestLineBreakWithOffset(CTTypesetterRef typesetter,
														 CFIndex startIndex,
														 double width, double offset)
{
	(void) typesetter;
	(void) startIndex;
	(void) width;
	(void) offset;
	return 0;
}
