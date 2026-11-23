/*
 This file is part of Darling.

 Copyright (C) 2019 Lubos Dolezel

 Darling is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 Darling is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with Darling.  If not, see <http://www.gnu.org/licenses/>.
*/

#import <AppKit/AppKitExport.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSGeometry.h>
#import <Foundation/NSArray.h>

@class NSImage, NSView;
@protocol NSSharingServiceDelegate, NSSharingServicePickerDelegate;

typedef NSString *NSSharingServiceName;

APPKIT_EXPORT NSSharingServiceName const NSSharingServiceNameAddToIPhoto;
APPKIT_EXPORT NSSharingServiceName const NSSharingServiceNameAddToSafariReadingList;
APPKIT_EXPORT NSSharingServiceName const NSSharingServiceNameComposeEmail;
APPKIT_EXPORT NSSharingServiceName const NSSharingServiceNameComposeMessage;

/* Deprecated */
APPKIT_EXPORT NSSharingServiceName const NSSharingServiceNamePostOnFacebook;
APPKIT_EXPORT NSSharingServiceName const NSSharingServiceNamePostOnLinkedIn;
APPKIT_EXPORT NSSharingServiceName const NSSharingServiceNamePostOnSinaWeibo;
APPKIT_EXPORT NSSharingServiceName const NSSharingServiceNamePostOnTencentWeibo;
APPKIT_EXPORT NSSharingServiceName const NSSharingServiceNamePostOnTwitter;

@interface NSSharingService : NSObject {
    id<NSSharingServiceDelegate> _delegate;
    NSString *_title;
    NSString *_subject;
    NSString *_accountName;
    NSImage *_image;
    NSImage *_alternateImage;
}

+ (NSArray *) sharingServicesForItems: (NSArray *) items;

- (id<NSSharingServiceDelegate>) delegate;
- (void) setDelegate: (id<NSSharingServiceDelegate>) delegate;
- (NSString *) title;
- (NSImage *) image;
- (NSImage *) alternateImage;
- (NSString *) subject;
- (void) setSubject: (NSString *) subject;
- (NSString *) accountName;
- (void) performWithItems: (NSArray *) items;

@end

@interface NSSharingServicePicker : NSObject {
    id<NSSharingServicePickerDelegate> _delegate;
    NSArray *_items;
}

- (id<NSSharingServicePickerDelegate>) delegate;
- (void) setDelegate: (id<NSSharingServicePickerDelegate>) delegate;
- (instancetype) initWithItems: (NSArray *) items;
- (void) showRelativeToRect: (NSRect) rect
                     ofView: (NSView *) view
              preferredEdge: (NSRectEdge) preferredEdge;

@end

@protocol NSSharingServiceDelegate <NSObject>
@optional
- (void) sharingService: (NSSharingService *) sharingService
         willShareItems: (NSArray *) items;
- (void) sharingService: (NSSharingService *) sharingService
    didFailToShareItems: (NSArray *) items
                  error: (NSError *) error;
- (void) sharingService: (NSSharingService *) sharingService
          didShareItems: (NSArray *) items;
@end

@protocol NSSharingServicePickerDelegate <NSObject>
@optional
- (void) sharingServicePicker: (NSSharingServicePicker *) sharingServicePicker
      didChooseSharingService: (NSSharingService *) service;
@end

// @interface NSItemProvider (NSCloudKitSharing)
// @end
