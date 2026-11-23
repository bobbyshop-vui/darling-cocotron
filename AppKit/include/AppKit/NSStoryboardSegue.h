/*
 This file is part of Darling.

 Copyright (C) 2025 Darling Developers

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

#import <Foundation/Foundation.h>
#import <AppKit/AppKitExport.h>

@interface NSStoryboardSegue : NSObject {
    void (^_performHandler)(void);
    NSString *_identifier;
    id _sourceController;
    id _destinationController;
    void (^_prepareHandler)(void);
}

+ (instancetype)segueWithIdentifier:(NSString *)identifier source:(id)sourceController destination:(id)destinationController performHandler:(void (^)(void))performHandler;

- (instancetype)initWithIdentifier:(NSString *)identifier source:(id)sourceController destination:(id)destinationController;

@property(readonly, copy) NSString *identifier;
@property(readonly, strong) id sourceController;
@property(readonly, strong) id destinationController;

- (NSString *)identifier;
- (void)perform;

@end

@protocol NSSeguePerforming <NSObject>
@optional
- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender;
- (void)performSegueWithIdentifier:(NSString *)identifier sender:(id)sender;
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender;
@end
