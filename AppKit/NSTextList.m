/* Copyright (c) 2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#import <AppKit/NSRaise.h>
#import <AppKit/NSTextList.h>

NSString *const NSTextListMarkerDecimal = @"{decimal}";
NSString *const NSTextListMarkerDisc = @"{disc}";

static NSString *NSTextListRomanNumber(unsigned int value, BOOL uppercase) {
    static const unsigned int values[] =
            {1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1};
    static NSString *const upper[] = {@"M",  @"CM", @"D",  @"CD", @"C",
                                      @"XC", @"L",  @"XL", @"X",  @"IX",
                                      @"V",  @"IV", @"I"};
    static NSString *const lower[] = {@"m",  @"cm", @"d",  @"cd", @"c",
                                      @"xc", @"l",  @"xl", @"x",  @"ix",
                                      @"v",  @"iv", @"i"};

    if (value == 0 || value > 3999999)
        return [NSString stringWithFormat: @"%u", value];

    NSMutableString *result = [NSMutableString string];
    for (NSUInteger index = 0; index < sizeof(values) / sizeof(values[0]);
         index++) {
        while (value >= values[index]) {
            [result appendString: uppercase ? upper[index] : lower[index]];
            value -= values[index];
        }
    }
    return result;
}

static NSString *NSTextListAlphaNumber(unsigned int value, BOOL uppercase) {
    if (value == 0)
        return @"0";

    NSMutableString *result = [NSMutableString string];
    while (value > 0) {
        value--;
        unichar character = (uppercase ? 'A' : 'a') + value % 26;
        [result insertString: [NSString stringWithCharacters: &character
                                                     length: 1]
                     atIndex: 0];
        value /= 26;
    }
    return result;
}

@implementation NSTextList

- initWithMarkerFormat: (NSString *) format options: (unsigned) options {
    _markerFormat = [format copy];
    _options = options;
    return self;
}

- (void) dealloc {
    [_markerFormat release];
    [super dealloc];
}

- (NSString *) markerFormat {
    return _markerFormat;
}

- (unsigned) listOptions {
    return _options;
}

- (NSString *) markerForItemNumber: (int) index {
    NSString *format = _markerFormat != nil ? _markerFormat
                                             : NSTextListMarkerDecimal;
    NSRange open = [format rangeOfString: @"{"];
    NSRange close = [format rangeOfString: @"}"
                                  options: NSBackwardsSearch];
    if (open.location == NSNotFound || close.location == NSNotFound ||
        close.location <= open.location)
        return format;

    NSString *kind = [format substringWithRange:
            NSMakeRange(open.location + 1, close.location - open.location - 1)];
    unsigned int itemNumber = index > 0 ? (unsigned int) index : 0;
    NSString *marker = nil;

    if ([kind isEqualToString: @"decimal"]) {
        marker = [NSString stringWithFormat: @"%u", itemNumber];
    } else if ([kind isEqualToString: @"upper-roman"] ||
               [kind isEqualToString: @"lower-roman"]) {
        marker = NSTextListRomanNumber(itemNumber,
                                       [kind isEqualToString: @"upper-roman"]);
    } else if ([kind isEqualToString: @"upper-alpha"] ||
               [kind isEqualToString: @"lower-alpha"] ||
               [kind isEqualToString: @"upper-latin"] ||
               [kind isEqualToString: @"lower-latin"]) {
        marker = NSTextListAlphaNumber(
                itemNumber, [kind isEqualToString: @"upper-alpha"] ||
                                    [kind isEqualToString: @"upper-latin"]);
    } else if ([kind isEqualToString: @"upper-hexadecimal"]) {
        marker = [NSString stringWithFormat: @"%X", itemNumber];
    } else if ([kind isEqualToString: @"lower-hexadecimal"]) {
        marker = [NSString stringWithFormat: @"%x", itemNumber];
    } else if ([kind isEqualToString: @"octal"]) {
        marker = [NSString stringWithFormat: @"%o", itemNumber];
    } else if ([kind isEqualToString: @"disc"]) {
        marker = @"•";
    } else if ([kind isEqualToString: @"circle"]) {
        marker = @"◦";
    } else if ([kind isEqualToString: @"square"]) {
        marker = @"▪";
    } else if ([kind isEqualToString: @"box"]) {
        marker = @"□";
    } else if ([kind isEqualToString: @"check"]) {
        marker = @"✓";
    } else if ([kind isEqualToString: @"diamond"]) {
        marker = @"◆";
    } else if ([kind isEqualToString: @"hyphen"]) {
        marker = @"-";
    } else {
        marker = [NSString stringWithFormat: @"%u", itemNumber];
    }

    return [NSString stringWithFormat: @"%@%@%@",
                                      [format substringToIndex: open.location],
                                      marker,
                                      [format substringFromIndex:
                                               close.location + 1]];
}

@end
