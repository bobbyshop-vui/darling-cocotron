#import <AppKit/AppKitExport.h>
#import <Foundation/NSString.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSNumber.h>
#import <Foundation/NSGeometry.h>
#import <Foundation/NSRange.h>
#import <objc/runtime.h>
#import <AppKit/NSAccessibilityConstants.h>
#import <AppKit/NSView.h>

NSString *const NSAccessibilityChildrenAttribute =
        @"NSAccessibilityChildrenAttribute";
NSString *const NSAccessibilityContentsAttribute =
        @"NSAccessibilityContentsAttribute";
NSString *const NSAccessibilityDescriptionAttribute =
        @"NSAccessibilityDescriptionAttribute";
NSString *const NSAccessibilityEnabledAttribute =
        @"NSAccessibilityEnabledAttribute";
NSString *const NSAccessibilityFocusedAttribute =
        @"NSAccessibilityFocusedAttribute";
NSString *const NSAccessibilityHelpAttribute = @"NSAccessibilityHelpAttribute";
NSString *const NSAccessibilityMaxValueAttribute =
        @"NSAccessibilityMaxValueAttribute";
NSString *const NSAccessibilityMinValueAttribute =
        @"NSAccessibilityMinValueAttribute";
NSString *const NSAccessibilityParentAttribute =
        @"NSAccessibilityParentAttribute";
NSString *const NSAccessibilityPositionAttribute =
        @"NSAccessibilityPositionAttribute";
NSString *const NSAccessibilityRoleAttribute = @"NSAccessibilityRoleAttribute";
NSString *const NSAccessibilityRoleDescriptionAttribute =
        @"NSAccessibilityRoleDescriptionAttribute";
NSString *const NSAccessibilitySelectedChildrenAttribute =
        @"NSAccessibilitySelectedChildrenAttribute";
NSString *const NSAccessibilityShownMenuAttribute =
        @"NSAccessibilityShownMenuAttribute";
NSString *const NSAccessibilitySizeAttribute = @"NSAccessibilitySizeAttribute";
NSString *const NSAccessibilitySubroleAttribute =
        @"NSAccessibilitySubroleAttribute";
NSString *const NSAccessibilityTitleAttribute =
        @"NSAccessibilityTitleAttribute";
NSString *const NSAccessibilityTopLevelUIElementAttribute =
        @"NSAccessibilityTopLevelUIElementAttribute";
NSString *const NSAccessibilityValueAttribute =
        @"NSAccessibilityValueAttribute";
NSString *const NSAccessibilityValueDescriptionAttribute =
        @"NSAccessibilityValueDescriptionAttribute";
NSString *const NSAccessibilityVisibleChildrenAttribute =
        @"NSAccessibilityVisibleChildrenAttribute";
NSString *const NSAccessibilityWindowAttribute =
        @"NSAccessibilityWindowAttribute";
NSString *const NSAccessibilityIdentifierAttribute =
        @"NSAccessibilityIdentifierAttribute";

NSString *const NSAccessibilityInsertionPointLineNumberAttribute =
        @"NSAccessibilityInsertionPointLineNumberAttribute";
NSString *const NSAccessibilityNumberOfCharactersAttribute =
        @"NSAccessibilityNumberOfCharactersAttribute";
NSString *const NSAccessibilitySelectedTextAttribute =
        @"NSAccessibilitySelectedTextAttribute";
NSString *const NSAccessibilitySelectedTextRangeAttribute =
        @"NSAccessibilitySelectedTextRangeAttribute";
NSString *const NSAccessibilitySelectedTextRangesAttribute =
        @"NSAccessibilitySelectedTextRangesAttribute";
NSString *const NSAccessibilitySharedCharacterRangeAttribute =
        @"NSAccessibilitySharedCharacterRangeAttribute";
NSString *const NSAccessibilitySharedTextUIElementsAttribute =
        @"NSAccessibilitySharedTextUIElementsAttribute";
NSString *const NSAccessibilityVisibleCharacterRangeAttribute =
        @"NSAccessibilityVisibleCharacterRangeAttribute";

NSString *const NSAccessibilityAttributedStringForRangeParameterizedAttribute =
        @"NSAccessibilityAttributedStringForRangeParameterizedAttribute";
NSString *const NSAccessibilityBoundsForRangeParameterizedAttribute =
        @"NSAccessibilityBoundsForRangeParameterizedAttribute";
NSString *const NSAccessibilityLineForIndexParameterizedAttribute =
        @"NSAccessibilityLineForIndexParameterizedAttribute";
NSString *const NSAccessibilityRTFForRangeParameterizedAttribute =
        @"NSAccessibilityRTFForRangeParameterizedAttribute";
NSString *const NSAccessibilityRangeForIndexParameterizedAttribute =
        @"NSAccessibilityRangeForIndexParameterizedAttribute";
NSString *const NSAccessibilityRangeForLineParameterizedAttribute =
        @"NSAccessibilityRangeForLineParameterizedAttribute";
NSString *const NSAccessibilityRangeForPositionParameterizedAttribute =
        @"NSAccessibilityRangeForPositionParameterizedAttribute";
NSString *const NSAccessibilityStringForRangeParameterizedAttribute =
        @"NSAccessibilityStringForRangeParameterizedAttribute";
NSString *const NSAccessibilityStyleRangeForIndexParameterizedAttribute =
        @"NSAccessibilityStyleRangeForIndexParameterizedAttribute";

NSString *const NSAccessibilityAttachmentTextAttribute =
        @"NSAccessibilityAttachmentTextAttribute";
NSString *const NSAccessibilityBackgroundColorTextAttribute =
        @"NSAccessibilityBackgroundColorTextAttribute";
NSString *const NSAccessibilityFontFamilyKey = @"NSAccessibilityFontFamilyKey";
NSString *const NSAccessibilityFontNameKey = @"NSAccessibilityFontNameKey";
NSString *const NSAccessibilityFontSizeKey = @"NSAccessibilityFontSizeKey";
NSString *const NSAccessibilityFontTextAttribute =
        @"NSAccessibilityFontTextAttribute";
NSString *const NSAccessibilityForegroundColorTextAttribute =
        @"NSAccessibilityForegroundColorTextAttribute";
NSString *const NSAccessibilityLinkTextAttribute =
        @"NSAccessibilityLinkTextAttribute";
NSAttributedStringKey const NSAccessibilityMarkedMisspelledTextAttribute = @"AXMarkedMisspelled";
NSString *const NSAccessibilityMisspelledTextAttribute =
        @"NSAccessibilityMisspelledTextAttribute";
NSString *const NSAccessibilityShadowTextAttribute =
        @"NSAccessibilityShadowTextAttribute";
NSString *const NSAccessibilityStrikethroughColorTextAttribute =
        @"NSAccessibilityStrikethroughColorTextAttribute";
NSString *const NSAccessibilityStrikethroughTextAttribute =
        @"NSAccessibilityStrikethroughTextAttribute";
NSString *const NSAccessibilitySuperscriptTextAttribute =
        @"NSAccessibilitySuperscriptTextAttribute";
NSString *const NSAccessibilityUnderlineColorTextAttribute =
        @"NSAccessibilityUnderlineColorTextAttribute";
NSString *const NSAccessibilityUnderlineTextAttribute =
        @"NSAccessibilityUnderlineTextAttribute";
NSString *const NSAccessibilityVisibleNameKey =
        @"NSAccessibilityVisibleNameKey";

NSString *const NSAccessibilityCancelButtonAttribute =
        @"NSAccessibilityCancelButtonAttribute";
NSString *const NSAccessibilityCloseButtonAttribute =
        @"NSAccessibilityCloseButtonAttribute";
NSString *const NSAccessibilityDefaultButtonAttribute =
        @"NSAccessibilityDefaultButtonAttribute";
NSString *const NSAccessibilityGrowAreaAttribute =
        @"NSAccessibilityGrowAreaAttribute";
NSString *const NSAccessibilityMainAttribute = @"NSAccessibilityMainAttribute";
NSString *const NSAccessibilityMinimizeButtonAttribute =
        @"NSAccessibilityMinimizeButtonAttribute";
NSString *const NSAccessibilityMinimizedAttribute =
        @"NSAccessibilityMinimizedAttribute";
NSString *const NSAccessibilityModalAttribute =
        @"NSAccessibilityModalAttribute";
NSString *const NSAccessibilityProxyAttribute =
        @"NSAccessibilityProxyAttribute";
NSString *const NSAccessibilityToolbarButtonAttribute =
        @"NSAccessibilityToolbarButtonAttribute";
NSString *const NSAccessibilityZoomButtonAttribute =
        @"NSAccessibilityZoomButtonAttribute";

NSString *const NSAccessibilityHorizontalOrientationValue =
        @"NSAccessibilityHorizontalOrientationValue";
NSString *const NSAccessibilityVerticalOrientationValue =
        @"NSAccessibilityVerticalOrientationValue";
NSString *const NSAccessibilityUnknownOrientationValue =
        @"NSAccessibilityUnknownOrientationValue";

NSString *const NSAccessibilityClearButtonAttribute =
        @"NSAccessibilityClearButtonAttribute";
NSString *const NSAccessibilityColumnTitlesAttribute =
        @"NSAccessibilityColumnTitlesAttribute";
NSString *const NSAccessibilityFocusedUIElementAttribute =
        @"NSAccessibilityFocusedUIElementAttribute";
NSString *const NSAccessibilityFocusedWindowAttribute =
        @"NSAccessibilityFocusedWindowAttribute";
NSString *const NSAccessibilityFrontmostAttribute =
        @"NSAccessibilityFrontmostAttribute";
NSString *const NSAccessibilityHiddenAttribute =
        @"NSAccessibilityHiddenAttribute";
NSString *const NSAccessibilityMainWindowAttribute =
        @"NSAccessibilityMainWindowAttribute";
NSString *const NSAccessibilityMenuBarAttribute =
        @"NSAccessibilityMenuBarAttribute";
NSString *const NSAccessibilityOrientationAttribute =
        @"NSAccessibilityOrientationAttribute";
NSString *const NSAccessibilitySearchButtonAttribute =
        @"NSAccessibilitySearchButtonAttribute";
NSString *const NSAccessibilitySearchMenuAttribute =
        @"NSAccessibilitySearchMenuAttribute";
NSString *const NSAccessibilityWindowsAttribute =
        @"NSAccessibilityWindowsAttribute";

NSString *const NSAccessibilityColumnCountAttribute =
        @"NSAccessibilityColumnCountAttribute";
NSString *const NSAccessibilityOrderedByRowAttribute =
        @"NSAccessibilityOrderedByRowAttribute";
NSString *const NSAccessibilityRowCountAttribute =
        @"NSAccessibilityRowCountAttribute";

NSString *const NSAccessibilityColumnHeaderUIElementsAttribute =
        @"NSAccessibilityColumnHeaderUIElementsAttribute";
NSString *const NSAccessibilityColumnsAttribute =
        @"NSAccessibilityColumnsAttribute";
NSString *const NSAccessibilityRowHeaderUIElementsAttribute =
        @"NSAccessibilityRowHeaderUIElementsAttribute";
NSString *const NSAccessibilityRowsAttribute = @"NSAccessibilityRowsAttribute";
NSString *const NSAccessibilitySelectedColumnsAttribute =
        @"NSAccessibilitySelectedColumnsAttribute";
NSString *const NSAccessibilitySelectedRowsAttribute =
        @"NSAccessibilitySelectedRowsAttribute";
NSString *const NSAccessibilitySortDirectionAttribute =
        @"NSAccessibilitySortDirectionAttribute";
NSString *const NSAccessibilityVisibleColumnsAttribute =
        @"NSAccessibilityVisibleColumnsAttribute";
NSString *const NSAccessibilityVisibleRowsAttribute =
        @"NSAccessibilityVisibleRowsAttribute";

NSString *const NSAccessibilityDisclosedByRowAttribute =
        @"NSAccessibilityDisclosedByRowAttribute";
NSString *const NSAccessibilityDisclosedRowsAttribute =
        @"NSAccessibilityDisclosedRowsAttribute";
NSString *const NSAccessibilityDisclosingAttribute =
        @"NSAccessibilityDisclosingAttribute";
NSString *const NSAccessibilityDisclosureLevelAttribute =
        @"NSAccessibilityDisclosureLevelAttribute";

NSString *const NSAccessibilitySelectedCellsAttribute =
        @"NSAccessibilitySelectedCellsAttribute";
NSString *const NSAccessibilityVisibleCellsAttribute =
        @"NSAccessibilityVisibleCellsAttribute";

NSString *const NSAccessibilityCellForColumnAndRowParameterizedAttribute =
        @"NSAccessibilityCellForColumnAndRowParameterizedAttribute";

NSString *const NSAccessibilityRowIndexRangeAttribute =
        @"NSAccessibilityRowIndexRangeAttribute";
NSString *const NSAccessibilityColumnIndexRangeAttribute =
        @"NSAccessibilityColumnIndexRangeAttribute";

NSString *const NSAccessibilityAscendingSortDirectionValue =
        @"NSAccessibilityAscendingSortDirectionValue";
NSString *const NSAccessibilityDescendingSortDirectionValue =
        @"NSAccessibilityDescendingSortDirectionValue";
NSString *const NSAccessibilityUnknownSortDirectionValue =
        @"NSAccessibilityUnknownSortDirectionValue";

NSString *const NSAccessibilityHorizontalUnitsAttribute =
        @"NSAccessibilityHorizontalUnitsAttribute";
NSString *const NSAccessibilityVerticalUnitsAttribute =
        @"NSAccessibilityVerticalUnitsAttribute";
NSString *const NSAccessibilityHorizontalUnitDescriptionAttribute =
        @"NSAccessibilityHorizontalUnitDescriptionAttribute";
NSString *const NSAccessibilityVerticalUnitDescriptionAttribute =
        @"NSAccessibilityVerticalUnitDescriptionAttribute";

NSString *const NSAccessibilityLayoutPointForScreenPointParameterizedAttribute =
        @"NSAccessibilityLayoutPointForScreenPointParameterizedAttribute";
NSString *const NSAccessibilityLayoutSizeForScreenSizeParameterizedAttribute =
        @"NSAccessibilityLayoutSizeForScreenSizeParameterizedAttribute";
NSString *const NSAccessibilityScreenPointForLayoutPointParameterizedAttribute =
        @"NSAccessibilityScreenPointForLayoutPointParameterizedAttribute";
NSString *const NSAccessibilityScreenSizeForLayoutSizeParameterizedAttribute =
        @"NSAccessibilityScreenSizeForLayoutSizeParameterizedAttribute";

NSString *const NSAccessibilityHandlesAttribute =
        @"NSAccessibilityHandlesAttribute";

NSString *const NSAccessibilityAllowedValuesAttribute =
        @"NSAccessibilityAllowedValuesAttribute";
NSString *const NSAccessibilityLabelUIElementsAttribute =
        @"NSAccessibilityLabelUIElementsAttribute";
NSString *const NSAccessibilityLabelValueAttribute =
        @"NSAccessibilityLabelValueAttribute";

NSString *const NSAccessibilityMatteContentUIElementAttribute =
        @"NSAccessibilityMatteContentUIElementAttribute";
NSString *const NSAccessibilityMatteHoleAttribute =
        @"NSAccessibilityMatteHoleAttribute";

NSString *const NSAccessibilityMarkerGroupUIElementAttribute =
        @"NSAccessibilityMarkerGroupUIElementAttribute";
NSString *const NSAccessibilityMarkerTypeAttribute =
        @"NSAccessibilityMarkerTypeAttribute";
NSString *const NSAccessibilityMarkerTypeDescriptionAttribute =
        @"NSAccessibilityMarkerTypeDescriptionAttribute";
NSString *const NSAccessibilityMarkerUIElementsAttribute =
        @"NSAccessibilityMarkerUIElementsAttribute";
NSString *const NSAccessibilityMarkerValuesAttribute =
        @"NSAccessibilityMarkerValuesAttribute";
NSString *const NSAccessibilityUnitDescriptionAttribute =
        @"NSAccessibilityUnitDescriptionAttribute";
NSString *const NSAccessibilityUnitsAttribute =
        @"NSAccessibilityUnitsAttribute";

NSString *const NSAccessibilityCenterTabStopMarkerTypeValue =
        @"NSAccessibilityCenterTabStopMarkerTypeValue";
NSString *const NSAccessibilityDecimalTabStopMarkerTypeValue =
        @"NSAccessibilityDecimalTabStopMarkerTypeValue";
NSString *const NSAccessibilityFirstLineIndentMarkerTypeValue =
        @"NSAccessibilityFirstLineIndentMarkerTypeValue";
NSString *const NSAccessibilityHeadIndentMarkerTypeValue =
        @"NSAccessibilityHeadIndentMarkerTypeValue";
NSString *const NSAccessibilityLeftTabStopMarkerTypeValue =
        @"NSAccessibilityLeftTabStopMarkerTypeValue";
NSString *const NSAccessibilityRightTabStopMarkerTypeValue =
        @"NSAccessibilityRightTabStopMarkerTypeValue";
NSString *const NSAccessibilityTailIndentMarkerTypeValue =
        @"NSAccessibilityTailIndentMarkerTypeValue";
NSString *const NSAccessibilityUnknownMarkerTypeValue =
        @"NSAccessibilityUnknownMarkerTypeValue";

NSString *const NSAccessibilityCentimetersUnitValue =
        @"NSAccessibilityCentimetersUnitValue";
NSString *const NSAccessibilityInchesUnitValue =
        @"NSAccessibilityInchesUnitValue";
NSString *const NSAccessibilityPicasUnitValue =
        @"NSAccessibilityPicasUnitValue";
NSString *const NSAccessibilityPointsUnitValue =
        @"NSAccessibilityPointsUnitValue";
NSString *const NSAccessibilityUnknownUnitValue =
        @"NSAccessibilityUnknownUnitValue";

NSString *const NSAccessibilityLinkedUIElementsAttribute =
        @"NSAccessibilityLinkedUIElementsAttribute";
NSString *const NSAccessibilityServesAsTitleForUIElementsAttribute =
        @"NSAccessibilityServesAsTitleForUIElementsAttribute";
NSString *const NSAccessibilityTitleUIElementAttribute =
        @"NSAccessibilityTitleUIElementAttribute";

NSString *const NSAccessibilityDecrementButtonAttribute =
        @"NSAccessibilityDecrementButtonAttribute";
NSString *const NSAccessibilityDocumentAttribute =
        @"NSAccessibilityDocumentAttribute";
NSString *const NSAccessibilityEditedAttribute =
        @"NSAccessibilityEditedAttribute";
NSString *const NSAccessibilityExpandedAttribute =
        @"NSAccessibilityExpandedAttribute";
NSString *const NSAccessibilityFilenameAttribute =
        @"NSAccessibilityFilenameAttribute";
NSString *const NSAccessibilityHeaderAttribute =
        @"NSAccessibilityHeaderAttribute";
NSString *const NSAccessibilityHorizontalScrollBarAttribute =
        @"NSAccessibilityHorizontalScrollBarAttribute";
NSString *const NSAccessibilityIncrementButtonAttribute =
        @"NSAccessibilityIncrementButtonAttribute";
NSString *const NSAccessibilityIndexAttribute =
        @"NSAccessibilityIndexAttribute";
NSString *const NSAccessibilityNextContentsAttribute =
        @"NSAccessibilityNextContentsAttribute";
NSString *const NSAccessibilityOverflowButtonAttribute =
        @"NSAccessibilityOverflowButtonAttribute";
NSString *const NSAccessibilityPreviousContentsAttribute =
        @"NSAccessibilityPreviousContentsAttribute";
NSString *const NSAccessibilitySelectedAttribute =
        @"NSAccessibilitySelectedAttribute";
NSString *const NSAccessibilitySplittersAttribute =
        @"NSAccessibilitySplittersAttribute";
NSString *const NSAccessibilityTabsAttribute = @"NSAccessibilityTabsAttribute";
NSString *const NSAccessibilityURLAttribute = @"NSAccessibilityURLAttribute";
NSString *const NSAccessibilityVerticalScrollBarAttribute =
        @"NSAccessibilityVerticalScrollBarAttribute";
NSString *const NSAccessibilityWarningValueAttribute =
        @"NSAccessibilityWarningValueAttribute";
NSString *const NSAccessibilityCriticalValueAttribute =
        @"NSAccessibilityCriticalValueAttribute";
NSString *const NSAccessibilityPlaceholderValueAttribute =
        @"NSAccessibilityPlaceholderValueAttribute";

NSString *const NSAccessibilityApplicationRole =
        @"NSAccessibilityApplicationRole";
NSString *const NSAccessibilityBrowserRole = @"NSAccessibilityBrowserRole";
NSString *const NSAccessibilityBusyIndicatorRole =
        @"NSAccessibilityBusyIndicatorRole";
NSString *const NSAccessibilityButtonRole = @"NSAccessibilityButtonRole";
NSString *const NSAccessibilityCellRole = @"NSAccessibilityCellRole";
NSString *const NSAccessibilityCheckBoxRole = @"NSAccessibilityCheckBoxRole";
NSString *const NSAccessibilityColorWellRole = @"NSAccessibilityColorWellRole";
NSString *const NSAccessibilityColumnRole = @"NSAccessibilityColumnRole";
NSString *const NSAccessibilityComboBoxRole = @"NSAccessibilityComboBoxRole";
NSString *const NSAccessibilityDisclosureTriangleRole =
        @"NSAccessibilityDisclosureTriangleRole";
NSString *const NSAccessibilityDrawerRole = @"NSAccessibilityDrawerRole";
NSString *const NSAccessibilityGridRole = @"NSAccessibilityGridRole";
NSString *const NSAccessibilityGroupRole = @"NSAccessibilityGroupRole";
NSString *const NSAccessibilityGrowAreaRole = @"NSAccessibilityGrowAreaRole";
NSString *const NSAccessibilityHandleRole = @"NSAccessibilityHandleRole";
NSString *const NSAccessibilityHelpTagRole = @"NSAccessibilityHelpTagRole";
NSString *const NSAccessibilityImageRole = @"NSAccessibilityImageRole";
NSString *const NSAccessibilityIncrementorRole =
        @"NSAccessibilityIncrementorRole";
NSString *const NSAccessibilityLayoutAreaRole =
        @"NSAccessibilityLayoutAreaRole";
NSString *const NSAccessibilityLayoutItemRole =
        @"NSAccessibilityLayoutItemRole";
NSAccessibilityRole const NSAccessibilityLevelIndicatorRole = @"AXLevelIndicator";
NSString *const NSAccessibilityLinkRole = @"NSAccessibilityLinkRole";
NSString *const NSAccessibilityListRole = @"NSAccessibilityListRole";
NSString *const NSAccessibilityMatteRole = @"NSAccessibilityMatteRole";
NSString *const NSAccessibilityMenuBarRole = @"NSAccessibilityMenuBarRole";
NSString *const NSAccessibilityMenuButtonRole =
        @"NSAccessibilityMenuButtonRole";
NSString *const NSAccessibilityMenuItemRole = @"NSAccessibilityMenuItemRole";
NSString *const NSAccessibilityMenuRole = @"NSAccessibilityMenuRole";
NSString *const NSAccessibilityOutlineRole = @"NSAccessibilityOutlineRole";
NSString *const NSAccessibilityPopUpButtonRole =
        @"NSAccessibilityPopUpButtonRole";
NSString *const NSAccessibilityProgressIndicatorRole =
        @"NSAccessibilityProgressIndicatorRole";
NSString *const NSAccessibilityRadioButtonRole =
        @"NSAccessibilityRadioButtonRole";
NSString *const NSAccessibilityRadioGroupRole =
        @"NSAccessibilityRadioGroupRole";
NSString *const NSAccessibilityRelevanceIndicatorRole =
        @"NSAccessibilityRelevanceIndicatorRole";
NSString *const NSAccessibilityRowRole = @"NSAccessibilityRowRole";
NSString *const NSAccessibilityRulerMarkerRole =
        @"NSAccessibilityRulerMarkerRole";
NSString *const NSAccessibilityRulerRole = @"NSAccessibilityRulerRole";
NSString *const NSAccessibilityScrollAreaRole =
        @"NSAccessibilityScrollAreaRole";
NSString *const NSAccessibilityScrollBarRole = @"NSAccessibilityScrollBarRole";
NSString *const NSAccessibilitySheetRole = @"NSAccessibilitySheetRole";
NSString *const NSAccessibilitySliderRole = @"NSAccessibilitySliderRole";
NSString *const NSAccessibilitySortButtonRole =
        @"NSAccessibilitySortButtonRole";
NSString *const NSAccessibilitySplitGroupRole =
        @"NSAccessibilitySplitGroupRole";
NSString *const NSAccessibilitySplitterRole = @"NSAccessibilitySplitterRole";
NSString *const NSAccessibilityStaticTextRole =
        @"NSAccessibilityStaticTextRole";
NSString *const NSAccessibilitySystemWideRole =
        @"NSAccessibilitySystemWideRole";
NSString *const NSAccessibilityTabGroupRole = @"NSAccessibilityTabGroupRole";
NSString *const NSAccessibilityTableRole = @"NSAccessibilityTableRole";
NSString *const NSAccessibilityTextAreaRole = @"NSAccessibilityTextAreaRole";
NSString *const NSAccessibilityTextFieldRole = @"NSAccessibilityTextFieldRole";
NSString *const NSAccessibilityToolbarRole = @"NSAccessibilityToolbarRole";
NSString *const NSAccessibilityUnknownRole = @"NSAccessibilityUnknownRole";
NSString *const NSAccessibilityValueIndicatorRole =
        @"NSAccessibilityValueIndicatorRole";
NSString *const NSAccessibilityWindowRole = @"NSAccessibilityWindowRole";

NSString *const NSAccessibilityCloseButtonSubrole =
        @"NSAccessibilityCloseButtonSubrole";
NSString *const NSAccessibilityDecrementArrowSubrole =
        @"NSAccessibilityDecrementArrowSubrole";
NSString *const NSAccessibilityDecrementPageSubrole =
        @"NSAccessibilityDecrementPageSubrole";
NSString *const NSAccessibilityDialogSubrole = @"NSAccessibilityDialogSubrole";
NSString *const NSAccessibilityFloatingWindowSubrole =
        @"NSAccessibilityFloatingWindowSubrole";
NSString *const NSAccessibilityIncrementArrowSubrole =
        @"NSAccessibilityIncrementArrowSubrole";
NSString *const NSAccessibilityIncrementPageSubrole =
        @"NSAccessibilityIncrementPageSubrole";
NSString *const NSAccessibilityMinimizeButtonSubrole =
        @"NSAccessibilityMinimizeButtonSubrole";
NSString *const NSAccessibilityOutlineRowSubrole =
        @"NSAccessibilityOutlineRowSubrole";
NSString *const NSAccessibilitySearchFieldSubrole =
        @"NSAccessibilitySearchFieldSubrole";
NSString *const NSAccessibilitySecureTextFieldSubrole =
        @"NSAccessibilitySecureTextFieldSubrole";
NSString *const NSAccessibilityStandardWindowSubrole =
        @"NSAccessibilityStandardWindowSubrole";
NSString *const NSAccessibilitySystemDialogSubrole =
        @"NSAccessibilitySystemDialogSubrole";
NSString *const NSAccessibilitySystemFloatingWindowSubrole =
        @"NSAccessibilitySystemFloatingWindowSubrole";
NSString *const NSAccessibilityTableRowSubrole =
        @"NSAccessibilityTableRowSubrole";
NSString *const NSAccessibilityTextAttachmentSubrole =
        @"NSAccessibilityTextAttachmentSubrole";
NSString *const NSAccessibilityTextLinkSubrole =
        @"NSAccessibilityTextLinkSubrole";
NSString *const NSAccessibilityTimelineSubrole =
        @"NSAccessibilityTimelineSubrole";
NSString *const NSAccessibilityToolbarButtonSubrole =
        @"NSAccessibilityToolbarButtonSubrole";
NSString *const NSAccessibilityUnknownSubrole =
        @"NSAccessibilityUnknownSubrole";
NSString *const NSAccessibilityZoomButtonSubrole =
        @"NSAccessibilityZoomButtonSubrole";
NSString *const NSAccessibilitySortButtonSubrole =
        @"NSAccessibilitySortButtonSubrole";
NSString *const NSAccessibilityRatingIndicatorSubrole =
        @"NSAccessibilityRatingIndicatorSubrole";
NSString *const NSAccessibilityContentListSubrole =
        @"NSAccessibilityContentListSubrole";
NSString *const NSAccessibilityDefinitionListSubrole =
        @"NSAccessibilityDefinitionListSubrole";

NSString *const NSAccessibilityCancelAction = @"NSAccessibilityCancelAction";
NSString *const NSAccessibilityConfirmAction = @"NSAccessibilityConfirmAction";
NSString *const NSAccessibilityDecrementAction =
        @"NSAccessibilityDecrementAction";
NSString *const NSAccessibilityDeleteAction = @"NSAccessibilityDeleteAction";
NSString *const NSAccessibilityIncrementAction =
        @"NSAccessibilityIncrementAction";
NSString *const NSAccessibilityPickAction = @"NSAccessibilityPickAction";
NSString *const NSAccessibilityPressAction = @"NSAccessibilityPressAction";
NSString *const NSAccessibilityRaiseAction = @"NSAccessibilityRaiseAction";
NSAccessibilityActionName const NSAccessibilityShowAlternateUIAction = @"AXShowAlternateUI";
NSAccessibilityActionName const NSAccessibilityShowDefaultUIAction = @"AXShowDefaultUI";
NSString *const NSAccessibilityShowMenuAction =
        @"NSAccessibilityShowMenuAction";

NSString *const NSAccessibilityMainWindowChangedNotification =
        @"NSAccessibilityMainWindowChangedNotification";
NSString *const NSAccessibilityFocusedWindowChangedNotification =
        @"NSAccessibilityFocusedWindowChangedNotification";
NSString *const NSAccessibilityFocusedUIElementChangedNotification =
        @"NSAccessibilityFocusedUIElementChangedNotification";

NSString *const NSAccessibilityWindowCreatedNotification =
        @"NSAccessibilityWindowCreatedNotification";
NSString *const NSAccessibilityWindowDeminiaturizedNotification =
        @"NSAccessibilityWindowDeminiaturizedNotification";
NSString *const NSAccessibilityWindowMiniaturizedNotification =
        @"NSAccessibilityWindowMiniaturizedNotification";
NSString *const NSAccessibilityWindowMovedNotification =
        @"NSAccessibilityWindowMovedNotification";
NSString *const NSAccessibilityWindowResizedNotification =
        @"NSAccessibilityWindowResizedNotification";

NSString *const NSAccessibilityApplicationActivatedNotification =
        @"NSAccessibilityApplicationActivatedNotification";
NSString *const NSAccessibilityApplicationDeactivatedNotification =
        @"NSAccessibilityApplicationDeactivatedNotification";
NSString *const NSAccessibilityApplicationHiddenNotification =
        @"NSAccessibilityApplicationHiddenNotification";
NSString *const NSAccessibilityApplicationShownNotification =
        @"NSAccessibilityApplicationShownNotification";

NSString *const NSAccessibilityDrawerCreatedNotification =
        @"NSAccessibilityDrawerCreatedNotification";
NSString *const NSAccessibilitySheetCreatedNotification =
        @"NSAccessibilitySheetCreatedNotification";

NSString *const NSAccessibilityCreatedNotification =
        @"NSAccessibilityCreatedNotification";
NSString *const NSAccessibilityMovedNotification =
        @"NSAccessibilityMovedNotification";
NSString *const NSAccessibilityResizedNotification =
        @"NSAccessibilityResizedNotification";
NSString *const NSAccessibilityTitleChangedNotification =
        @"NSAccessibilityTitleChangedNotification";
NSString *const NSAccessibilityUIElementDestroyedNotification =
        @"NSAccessibilityUIElementDestroyedNotification";
NSString *const NSAccessibilityValueChangedNotification =
        @"NSAccessibilityValueChangedNotification";

NSString *const NSAccessibilityHelpTagCreatedNotification =
        @"NSAccessibilityHelpTagCreatedNotification";
NSString *const NSAccessibilityRowCountChangedNotification =
        @"NSAccessibilityRowCountChangedNotification";
NSString *const NSAccessibilitySelectedChildrenChangedNotification =
        @"NSAccessibilitySelectedChildrenChangedNotification";
NSString *const NSAccessibilitySelectedColumnsChangedNotification =
        @"NSAccessibilitySelectedColumnsChangedNotification";
NSString *const NSAccessibilitySelectedRowsChangedNotification =
        @"NSAccessibilitySelectedRowsChangedNotification";
NSString *const NSAccessibilitySelectedTextChangedNotification =
        @"NSAccessibilitySelectedTextChangedNotification";
NSString *const NSAccessibilityRowExpandedNotification =
        @"NSAccessibilityRowExpandedNotification";
NSString *const NSAccessibilityRowCollapsedNotification =
        @"NSAccessibilityRowCollapsedNotification";
NSString *const NSAccessibilitySelectedCellsChangedNotification =
        @"NSAccessibilitySelectedCellsChangedNotification";
NSString *const NSAccessibilityUnitsChangedNotification =
        @"NSAccessibilityUnitsChangedNotification";
NSString *const NSAccessibilitySelectedChildrenMovedNotification =
        @"NSAccessibilitySelectedChildrenMovedNotification";

NSString *const NSAccessibilityErrorCodeExceptionInfo =
        @"NSAccessibilityErrorCodeExceptionInfo";

/* The above constants are probably all wrong */
/* The one below is right */
NSString *const NSAccessibilityActivationPointAttribute = @"AXActivationPoint";

/* Undocumented */
NSString *const NSAccessibilityEventProcessedNotification = @"AXEventProcessed";
NSString *const NSAccessibilityEventSourceProcessIDKey =
        @"AXEventSourceProcessIDKey";
NSString *const NSAccessibilityEventSourceStateIDKey = @"AXEventSourceStateID";
NSString *const NSAccessibilityEventSourceUserDataKey =
        @"AXEventSourceUserDataKey";
NSString *const NSAccessibilityEventTimestampKey = @"AXEventTimestampKey";
NSString *const NSAccessibilityMainThreadIdleNotification = @"AXMainThreadIdle";
NSString *const NSAccessibilitySupportsMainThreadIdleNotificationAttribute =
        @"AXSupportsMainThreadIdleNotification";
/* End undocumented */

NSString *const NSAccessibilityLayoutChangedNotification = @"AXLayoutChanged";
NSString *const NSAccessibilityUIElementsKey = @"AXUIElementsKey";
NSString *const NSAccessibilityToggleSubrole = @"NSAccessibilityToggleSubrole";

NSString *const NSAccessibilityFullScreenButtonSubrole = @"AXFullScreenButton";

NSString *const NSAccessibilityAnnouncementKey = @"AXAnnouncementKey";
NSString *const NSAccessibilityAnnouncementRequestedNotification = @"AXAnnouncementRequested";
NSString *const NSAccessibilityPriorityKey = @"AXPriorityKey";

NSRect NSAccessibilityFrameInView(NSView *parentView, NSRect frame) {
    printf("STUB %s\n", __PRETTY_FUNCTION__);
    return frame;
}

void NSAccessibilityPostNotification(id element, NSString *notification) {
}

NSString *NSAccessibilityRoleDescription(NSString *role, NSString *subrole) {
    return nil;
}

id NSAccessibilityUnignoredAncestor(id element) {
    return nil;
}

id NSAccessibilityUnignoredDescendant(id element) {
    printf("STUB %s\n", __PRETTY_FUNCTION__);
    return nil;
}

NSArray *NSAccessibilityUnignoredChildren(NSArray *originalChildren) {
    printf("STUB %s\n", __PRETTY_FUNCTION__);
    return nil;
}

NSArray *NSAccessibilityUnignoredChildrenForOnlyChild(id originalChild) {
    printf("STUB %s\n", __PRETTY_FUNCTION__);
    return nil;
}

void NSAccessibilityPostNotificationWithUserInfo(id element,
                                                 NSAccessibilityNotificationName notification,
                                                 NSDictionary<NSAccessibilityNotificationUserInfoKey, id> *userInfo)
{
    printf("STUB %s\n", __PRETTY_FUNCTION__);
}

/*
 * NSAccessibility protocol properties, implemented once on NSObject.
 *
 * Darling's AppKit header only declares -isAccessibilityElement, but
 * AppKit itself (and applications such as Xcode) treat every attribute
 * in NSAccessibilityProtocols.h as a real property, e.g.
 * -[NSWindow setAccessibilityTitle:].  Without these methods those
 * messages raise NSInvalidArgumentException and abort the app.
 *
 * Values live in a per-object dictionary; nothing is exposed to an
 * accessibility client because Darling does not run one.
 */

#import <objc/runtime.h>

static char DarlingAXStorageKey;

static NSMutableDictionary *DarlingAXStorage(id object) {
    NSMutableDictionary *storage =
            objc_getAssociatedObject(object, &DarlingAXStorageKey);
    if (storage == nil) {
        storage = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(object, &DarlingAXStorageKey, storage,
                                 OBJC_ASSOCIATION_RETAIN);
        [storage release];
    }
    return storage;
}

static id DarlingAXValue(id object, NSString *key) {
    NSMutableDictionary *storage = DarlingAXStorage(object);
    @synchronized (storage) {
        return [[[storage objectForKey: key] retain] autorelease];
    }
}

static void DarlingAXSetValue(id object, NSString *key, id value) {
    NSMutableDictionary *storage = DarlingAXStorage(object);
    @synchronized (storage) {
        if (value != nil)
            [storage setObject: value forKey: key];
        else
            [storage removeObjectForKey: key];
    }
}

@implementation NSObject (DarlingAccessibilityProperties)

- (BOOL)isAccessibilityElement {
    NSNumber *value = DarlingAXValue(self, @"accessibilityElement");
    return value != nil ? [value boolValue] : NO;
}

- (void)setAccessibilityElement:(BOOL)value {
    DarlingAXSetValue(self, @"accessibilityElement", [NSNumber numberWithBool: value]);
}

- (NSRect)accessibilityFrame {
    NSValue *value = DarlingAXValue(self, @"accessibilityFrame");
    return value != nil ? [value rectValue] : NSZeroRect;
}

- (void)setAccessibilityFrame:(NSRect)value {
    DarlingAXSetValue(self, @"accessibilityFrame", [NSValue valueWithRect: value]);
}

- (BOOL)isAccessibilityFocused {
    NSNumber *value = DarlingAXValue(self, @"accessibilityFocused");
    return value != nil ? [value boolValue] : NO;
}

- (void)setAccessibilityFocused:(BOOL)value {
    DarlingAXSetValue(self, @"accessibilityFocused", [NSNumber numberWithBool: value]);
}

- (NSPoint)accessibilityActivationPoint {
    NSValue *value = DarlingAXValue(self, @"accessibilityActivationPoint");
    return value != nil ? [value pointValue] : NSZeroPoint;
}

- (void)setAccessibilityActivationPoint:(NSPoint)value {
    DarlingAXSetValue(self, @"accessibilityActivationPoint", [NSValue valueWithPoint: value]);
}

- (id)accessibilityTopLevelUIElement {
    return DarlingAXValue(self, @"accessibilityTopLevelUIElement");
}

- (void)setAccessibilityTopLevelUIElement:(id)value {
    DarlingAXSetValue(self, @"accessibilityTopLevelUIElement", value);
}

- (NSURL *)accessibilityURL {
    return DarlingAXValue(self, @"accessibilityURL");
}

- (void)setAccessibilityURL:(NSURL *)value {
    DarlingAXSetValue(self, @"accessibilityURL", value);
}

- (id)accessibilityValue {
    return DarlingAXValue(self, @"accessibilityValue");
}

- (void)setAccessibilityValue:(id)value {
    DarlingAXSetValue(self, @"accessibilityValue", value);
}

- (NSString *)accessibilityValueDescription {
    return DarlingAXValue(self, @"accessibilityValueDescription");
}

- (void)setAccessibilityValueDescription:(NSString *)value {
    DarlingAXSetValue(self, @"accessibilityValueDescription", value);
}

- (NSArray *)accessibilityVisibleChildren {
    return DarlingAXValue(self, @"accessibilityVisibleChildren");
}

- (void)setAccessibilityVisibleChildren:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilityVisibleChildren", value);
}

- (NSAccessibilitySubrole)accessibilitySubrole {
    return DarlingAXValue(self, @"accessibilitySubrole");
}

- (void)setAccessibilitySubrole:(NSAccessibilitySubrole)value {
    DarlingAXSetValue(self, @"accessibilitySubrole", value);
}

- (NSString *)accessibilityTitle {
    return DarlingAXValue(self, @"accessibilityTitle");
}

- (void)setAccessibilityTitle:(NSString *)value {
    DarlingAXSetValue(self, @"accessibilityTitle", value);
}

- (id)accessibilityTitleUIElement {
    return DarlingAXValue(self, @"accessibilityTitleUIElement");
}

- (void)setAccessibilityTitleUIElement:(id)value {
    DarlingAXSetValue(self, @"accessibilityTitleUIElement", value);
}

- (NSArray *)accessibilityNextContents {
    return DarlingAXValue(self, @"accessibilityNextContents");
}

- (void)setAccessibilityNextContents:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilityNextContents", value);
}

- (NSAccessibilityOrientation)accessibilityOrientation {
    NSNumber *value = DarlingAXValue(self, @"accessibilityOrientation");
    return value != nil ? [value integerValue] : 0;
}

- (void)setAccessibilityOrientation:(NSAccessibilityOrientation)value {
    DarlingAXSetValue(self, @"accessibilityOrientation", [NSNumber numberWithInteger: (NSInteger)value]);
}

- (id)accessibilityOverflowButton {
    return DarlingAXValue(self, @"accessibilityOverflowButton");
}

- (void)setAccessibilityOverflowButton:(id)value {
    DarlingAXSetValue(self, @"accessibilityOverflowButton", value);
}

- (id)accessibilityParent {
    return DarlingAXValue(self, @"accessibilityParent");
}

- (void)setAccessibilityParent:(id)value {
    DarlingAXSetValue(self, @"accessibilityParent", value);
}

- (NSString *)accessibilityPlaceholderValue {
    return DarlingAXValue(self, @"accessibilityPlaceholderValue");
}

- (void)setAccessibilityPlaceholderValue:(NSString *)value {
    DarlingAXSetValue(self, @"accessibilityPlaceholderValue", value);
}

- (NSArray *)accessibilityPreviousContents {
    return DarlingAXValue(self, @"accessibilityPreviousContents");
}

- (void)setAccessibilityPreviousContents:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilityPreviousContents", value);
}

- (NSAccessibilityRole)accessibilityRole {
    return DarlingAXValue(self, @"accessibilityRole");
}

- (void)setAccessibilityRole:(NSAccessibilityRole)value {
    DarlingAXSetValue(self, @"accessibilityRole", value);
}

- (NSString *)accessibilityRoleDescription {
    return DarlingAXValue(self, @"accessibilityRoleDescription");
}

- (void)setAccessibilityRoleDescription:(NSString *)value {
    DarlingAXSetValue(self, @"accessibilityRoleDescription", value);
}

- (id)accessibilitySearchButton {
    return DarlingAXValue(self, @"accessibilitySearchButton");
}

- (void)setAccessibilitySearchButton:(id)value {
    DarlingAXSetValue(self, @"accessibilitySearchButton", value);
}

- (id)accessibilitySearchMenu {
    return DarlingAXValue(self, @"accessibilitySearchMenu");
}

- (void)setAccessibilitySearchMenu:(id)value {
    DarlingAXSetValue(self, @"accessibilitySearchMenu", value);
}

- (BOOL)isAccessibilitySelected {
    NSNumber *value = DarlingAXValue(self, @"accessibilitySelected");
    return value != nil ? [value boolValue] : NO;
}

- (void)setAccessibilitySelected:(BOOL)value {
    DarlingAXSetValue(self, @"accessibilitySelected", [NSNumber numberWithBool: value]);
}

- (NSArray *)accessibilitySelectedChildren {
    return DarlingAXValue(self, @"accessibilitySelectedChildren");
}

- (void)setAccessibilitySelectedChildren:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilitySelectedChildren", value);
}

- (NSArray *)accessibilityServesAsTitleForUIElements {
    return DarlingAXValue(self, @"accessibilityServesAsTitleForUIElements");
}

- (void)setAccessibilityServesAsTitleForUIElements:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilityServesAsTitleForUIElements", value);
}

- (id)accessibilityShownMenu {
    return DarlingAXValue(self, @"accessibilityShownMenu");
}

- (void)setAccessibilityShownMenu:(id)value {
    DarlingAXSetValue(self, @"accessibilityShownMenu", value);
}

- (id)accessibilityMinValue {
    return DarlingAXValue(self, @"accessibilityMinValue");
}

- (void)setAccessibilityMinValue:(id)value {
    DarlingAXSetValue(self, @"accessibilityMinValue", value);
}

- (id)accessibilityMaxValue {
    return DarlingAXValue(self, @"accessibilityMaxValue");
}

- (void)setAccessibilityMaxValue:(id)value {
    DarlingAXSetValue(self, @"accessibilityMaxValue", value);
}

- (NSArray *)accessibilityLinkedUIElements {
    return DarlingAXValue(self, @"accessibilityLinkedUIElements");
}

- (void)setAccessibilityLinkedUIElements:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilityLinkedUIElements", value);
}

- (id)accessibilityWindow {
    return DarlingAXValue(self, @"accessibilityWindow");
}

- (void)setAccessibilityWindow:(id)value {
    DarlingAXSetValue(self, @"accessibilityWindow", value);
}

- (NSString *)accessibilityIdentifier {
    return DarlingAXValue(self, @"accessibilityIdentifier");
}

- (void)setAccessibilityIdentifier:(NSString *)value {
    DarlingAXSetValue(self, @"accessibilityIdentifier", value);
}

- (NSString *)accessibilityHelp {
    return DarlingAXValue(self, @"accessibilityHelp");
}

- (void)setAccessibilityHelp:(NSString *)value {
    DarlingAXSetValue(self, @"accessibilityHelp", value);
}

- (NSString *)accessibilityFilename {
    return DarlingAXValue(self, @"accessibilityFilename");
}

- (void)setAccessibilityFilename:(NSString *)value {
    DarlingAXSetValue(self, @"accessibilityFilename", value);
}

- (BOOL)isAccessibilityExpanded {
    NSNumber *value = DarlingAXValue(self, @"accessibilityExpanded");
    return value != nil ? [value boolValue] : NO;
}

- (void)setAccessibilityExpanded:(BOOL)value {
    DarlingAXSetValue(self, @"accessibilityExpanded", [NSNumber numberWithBool: value]);
}

- (BOOL)isAccessibilityEdited {
    NSNumber *value = DarlingAXValue(self, @"accessibilityEdited");
    return value != nil ? [value boolValue] : NO;
}

- (void)setAccessibilityEdited:(BOOL)value {
    DarlingAXSetValue(self, @"accessibilityEdited", [NSNumber numberWithBool: value]);
}

- (BOOL)isAccessibilityEnabled {
    NSNumber *value = DarlingAXValue(self, @"accessibilityEnabled");
    return value != nil ? [value boolValue] : NO;
}

- (void)setAccessibilityEnabled:(BOOL)value {
    DarlingAXSetValue(self, @"accessibilityEnabled", [NSNumber numberWithBool: value]);
}

- (NSArray *)accessibilityChildren {
    return DarlingAXValue(self, @"accessibilityChildren");
}

- (void)setAccessibilityChildren:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilityChildren", value);
}

- (NSArray *)accessibilityChildrenInNavigationOrder {
    return DarlingAXValue(self, @"accessibilityChildrenInNavigationOrder");
}

- (void)setAccessibilityChildrenInNavigationOrder:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilityChildrenInNavigationOrder", value);
}

- (id)accessibilityClearButton {
    return DarlingAXValue(self, @"accessibilityClearButton");
}

- (void)setAccessibilityClearButton:(id)value {
    DarlingAXSetValue(self, @"accessibilityClearButton", value);
}

- (id)accessibilityCancelButton {
    return DarlingAXValue(self, @"accessibilityCancelButton");
}

- (void)setAccessibilityCancelButton:(id)value {
    DarlingAXSetValue(self, @"accessibilityCancelButton", value);
}

- (BOOL)isAccessibilityProtectedContent {
    NSNumber *value = DarlingAXValue(self, @"accessibilityProtectedContent");
    return value != nil ? [value boolValue] : NO;
}

- (void)setAccessibilityProtectedContent:(BOOL)value {
    DarlingAXSetValue(self, @"accessibilityProtectedContent", [NSNumber numberWithBool: value]);
}

- (NSArray *)accessibilityContents {
    return DarlingAXValue(self, @"accessibilityContents");
}

- (void)setAccessibilityContents:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilityContents", value);
}

- (NSString *)accessibilityLabel {
    return DarlingAXValue(self, @"accessibilityLabel");
}

- (void)setAccessibilityLabel:(NSString *)value {
    DarlingAXSetValue(self, @"accessibilityLabel", value);
}

- (BOOL)isAccessibilityAlternateUIVisible {
    NSNumber *value = DarlingAXValue(self, @"accessibilityAlternateUIVisible");
    return value != nil ? [value boolValue] : NO;
}

- (void)setAccessibilityAlternateUIVisible:(BOOL)value {
    DarlingAXSetValue(self, @"accessibilityAlternateUIVisible", [NSNumber numberWithBool: value]);
}

- (NSArray *)accessibilitySharedFocusElements {
    return DarlingAXValue(self, @"accessibilitySharedFocusElements");
}

- (void)setAccessibilitySharedFocusElements:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilitySharedFocusElements", value);
}

- (BOOL)isAccessibilityRequired {
    NSNumber *value = DarlingAXValue(self, @"accessibilityRequired");
    return value != nil ? [value boolValue] : NO;
}

- (void)setAccessibilityRequired:(BOOL)value {
    DarlingAXSetValue(self, @"accessibilityRequired", [NSNumber numberWithBool: value]);
}

- (NSArray *)accessibilityCustomRotors {
    return DarlingAXValue(self, @"accessibilityCustomRotors");
}

- (void)setAccessibilityCustomRotors:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilityCustomRotors", value);
}

- (id)accessibilityApplicationFocusedUIElement {
    return DarlingAXValue(self, @"accessibilityApplicationFocusedUIElement");
}

- (void)setAccessibilityApplicationFocusedUIElement:(id)value {
    DarlingAXSetValue(self, @"accessibilityApplicationFocusedUIElement", value);
}

- (id)accessibilityMainWindow {
    return DarlingAXValue(self, @"accessibilityMainWindow");
}

- (void)setAccessibilityMainWindow:(id)value {
    DarlingAXSetValue(self, @"accessibilityMainWindow", value);
}

- (BOOL)isAccessibilityHidden {
    NSNumber *value = DarlingAXValue(self, @"accessibilityHidden");
    return value != nil ? [value boolValue] : NO;
}

- (void)setAccessibilityHidden:(BOOL)value {
    DarlingAXSetValue(self, @"accessibilityHidden", [NSNumber numberWithBool: value]);
}

- (BOOL)isAccessibilityFrontmost {
    NSNumber *value = DarlingAXValue(self, @"accessibilityFrontmost");
    return value != nil ? [value boolValue] : NO;
}

- (void)setAccessibilityFrontmost:(BOOL)value {
    DarlingAXSetValue(self, @"accessibilityFrontmost", [NSNumber numberWithBool: value]);
}

- (id)accessibilityFocusedWindow {
    return DarlingAXValue(self, @"accessibilityFocusedWindow");
}

- (void)setAccessibilityFocusedWindow:(id)value {
    DarlingAXSetValue(self, @"accessibilityFocusedWindow", value);
}

- (NSArray *)accessibilityWindows {
    return DarlingAXValue(self, @"accessibilityWindows");
}

- (void)setAccessibilityWindows:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilityWindows", value);
}

- (id)accessibilityExtrasMenuBar {
    return DarlingAXValue(self, @"accessibilityExtrasMenuBar");
}

- (void)setAccessibilityExtrasMenuBar:(id)value {
    DarlingAXSetValue(self, @"accessibilityExtrasMenuBar", value);
}

- (id)accessibilityMenuBar {
    return DarlingAXValue(self, @"accessibilityMenuBar");
}

- (void)setAccessibilityMenuBar:(id)value {
    DarlingAXSetValue(self, @"accessibilityMenuBar", value);
}

- (NSArray *)accessibilityColumnTitles {
    return DarlingAXValue(self, @"accessibilityColumnTitles");
}

- (void)setAccessibilityColumnTitles:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilityColumnTitles", value);
}

- (BOOL)isAccessibilityOrderedByRow {
    NSNumber *value = DarlingAXValue(self, @"accessibilityOrderedByRow");
    return value != nil ? [value boolValue] : NO;
}

- (void)setAccessibilityOrderedByRow:(BOOL)value {
    DarlingAXSetValue(self, @"accessibilityOrderedByRow", [NSNumber numberWithBool: value]);
}

- (NSAccessibilityUnits)accessibilityHorizontalUnits {
    NSNumber *value = DarlingAXValue(self, @"accessibilityHorizontalUnits");
    return value != nil ? [value integerValue] : 0;
}

- (void)setAccessibilityHorizontalUnits:(NSAccessibilityUnits)value {
    DarlingAXSetValue(self, @"accessibilityHorizontalUnits", [NSNumber numberWithInteger: (NSInteger)value]);
}

- (NSAccessibilityUnits)accessibilityVerticalUnits {
    NSNumber *value = DarlingAXValue(self, @"accessibilityVerticalUnits");
    return value != nil ? [value integerValue] : 0;
}

- (void)setAccessibilityVerticalUnits:(NSAccessibilityUnits)value {
    DarlingAXSetValue(self, @"accessibilityVerticalUnits", [NSNumber numberWithInteger: (NSInteger)value]);
}

- (NSString *)accessibilityHorizontalUnitDescription {
    return DarlingAXValue(self, @"accessibilityHorizontalUnitDescription");
}

- (void)setAccessibilityHorizontalUnitDescription:(NSString *)value {
    DarlingAXSetValue(self, @"accessibilityHorizontalUnitDescription", value);
}

- (NSString *)accessibilityVerticalUnitDescription {
    return DarlingAXValue(self, @"accessibilityVerticalUnitDescription");
}

- (void)setAccessibilityVerticalUnitDescription:(NSString *)value {
    DarlingAXSetValue(self, @"accessibilityVerticalUnitDescription", value);
}

- (NSArray *)accessibilityHandles {
    return DarlingAXValue(self, @"accessibilityHandles");
}

- (void)setAccessibilityHandles:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilityHandles", value);
}

- (id)accessibilityWarningValue {
    return DarlingAXValue(self, @"accessibilityWarningValue");
}

- (void)setAccessibilityWarningValue:(id)value {
    DarlingAXSetValue(self, @"accessibilityWarningValue", value);
}

- (id)accessibilityCriticalValue {
    return DarlingAXValue(self, @"accessibilityCriticalValue");
}

- (void)setAccessibilityCriticalValue:(id)value {
    DarlingAXSetValue(self, @"accessibilityCriticalValue", value);
}

- (BOOL)isAccessibilityDisclosed {
    NSNumber *value = DarlingAXValue(self, @"accessibilityDisclosed");
    return value != nil ? [value boolValue] : NO;
}

- (void)setAccessibilityDisclosed:(BOOL)value {
    DarlingAXSetValue(self, @"accessibilityDisclosed", [NSNumber numberWithBool: value]);
}

- (id)accessibilityDisclosedByRow {
    return DarlingAXValue(self, @"accessibilityDisclosedByRow");
}

- (void)setAccessibilityDisclosedByRow:(id)value {
    DarlingAXSetValue(self, @"accessibilityDisclosedByRow", value);
}

- (id)accessibilityDisclosedRows {
    return DarlingAXValue(self, @"accessibilityDisclosedRows");
}

- (void)setAccessibilityDisclosedRows:(id)value {
    DarlingAXSetValue(self, @"accessibilityDisclosedRows", value);
}

- (NSInteger)accessibilityDisclosureLevel {
    NSNumber *value = DarlingAXValue(self, @"accessibilityDisclosureLevel");
    return value != nil ? (NSInteger)[value integerValue] : 0;
}

- (void)setAccessibilityDisclosureLevel:(NSInteger)value {
    DarlingAXSetValue(self, @"accessibilityDisclosureLevel", [NSNumber numberWithInteger: (NSInteger)value]);
}

- (NSArray *)accessibilityMarkerUIElements {
    return DarlingAXValue(self, @"accessibilityMarkerUIElements");
}

- (void)setAccessibilityMarkerUIElements:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilityMarkerUIElements", value);
}

- (id)accessibilityMarkerValues {
    return DarlingAXValue(self, @"accessibilityMarkerValues");
}

- (void)setAccessibilityMarkerValues:(id)value {
    DarlingAXSetValue(self, @"accessibilityMarkerValues", value);
}

- (id)accessibilityMarkerGroupUIElement {
    return DarlingAXValue(self, @"accessibilityMarkerGroupUIElement");
}

- (void)setAccessibilityMarkerGroupUIElement:(id)value {
    DarlingAXSetValue(self, @"accessibilityMarkerGroupUIElement", value);
}

- (NSAccessibilityUnits)accessibilityUnits {
    NSNumber *value = DarlingAXValue(self, @"accessibilityUnits");
    return value != nil ? [value integerValue] : 0;
}

- (void)setAccessibilityUnits:(NSAccessibilityUnits)value {
    DarlingAXSetValue(self, @"accessibilityUnits", [NSNumber numberWithInteger: (NSInteger)value]);
}

- (NSString *)accessibilityUnitDescription {
    return DarlingAXValue(self, @"accessibilityUnitDescription");
}

- (void)setAccessibilityUnitDescription:(NSString *)value {
    DarlingAXSetValue(self, @"accessibilityUnitDescription", value);
}

- (NSAccessibilityRulerMarkerType)accessibilityRulerMarkerType {
    NSNumber *value = DarlingAXValue(self, @"accessibilityRulerMarkerType");
    return value != nil ? [value integerValue] : 0;
}

- (void)setAccessibilityRulerMarkerType:(NSAccessibilityRulerMarkerType)value {
    DarlingAXSetValue(self, @"accessibilityRulerMarkerType", [NSNumber numberWithInteger: (NSInteger)value]);
}

- (NSString *)accessibilityMarkerTypeDescription {
    return DarlingAXValue(self, @"accessibilityMarkerTypeDescription");
}

- (void)setAccessibilityMarkerTypeDescription:(NSString *)value {
    DarlingAXSetValue(self, @"accessibilityMarkerTypeDescription", value);
}

- (id)accessibilityHorizontalScrollBar {
    return DarlingAXValue(self, @"accessibilityHorizontalScrollBar");
}

- (void)setAccessibilityHorizontalScrollBar:(id)value {
    DarlingAXSetValue(self, @"accessibilityHorizontalScrollBar", value);
}

- (id)accessibilityVerticalScrollBar {
    return DarlingAXValue(self, @"accessibilityVerticalScrollBar");
}

- (void)setAccessibilityVerticalScrollBar:(id)value {
    DarlingAXSetValue(self, @"accessibilityVerticalScrollBar", value);
}

- (NSArray *)accessibilityAllowedValues {
    return DarlingAXValue(self, @"accessibilityAllowedValues");
}

- (void)setAccessibilityAllowedValues:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilityAllowedValues", value);
}

- (NSArray *)accessibilityLabelUIElements {
    return DarlingAXValue(self, @"accessibilityLabelUIElements");
}

- (void)setAccessibilityLabelUIElements:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilityLabelUIElements", value);
}

- (float)accessibilityLabelValue {
    NSNumber *value = DarlingAXValue(self, @"accessibilityLabelValue");
    return value != nil ? [value floatValue] : 0.0f;
}

- (void)setAccessibilityLabelValue:(float)value {
    DarlingAXSetValue(self, @"accessibilityLabelValue", [NSNumber numberWithFloat: value]);
}

- (NSArray *)accessibilitySplitters {
    return DarlingAXValue(self, @"accessibilitySplitters");
}

- (void)setAccessibilitySplitters:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilitySplitters", value);
}

- (id)accessibilityDecrementButton {
    return DarlingAXValue(self, @"accessibilityDecrementButton");
}

- (void)setAccessibilityDecrementButton:(id)value {
    DarlingAXSetValue(self, @"accessibilityDecrementButton", value);
}

- (id)accessibilityIncrementButton {
    return DarlingAXValue(self, @"accessibilityIncrementButton");
}

- (void)setAccessibilityIncrementButton:(id)value {
    DarlingAXSetValue(self, @"accessibilityIncrementButton", value);
}

- (NSArray *)accessibilityTabs {
    return DarlingAXValue(self, @"accessibilityTabs");
}

- (void)setAccessibilityTabs:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilityTabs", value);
}

- (id)accessibilityHeader {
    return DarlingAXValue(self, @"accessibilityHeader");
}

- (void)setAccessibilityHeader:(id)value {
    DarlingAXSetValue(self, @"accessibilityHeader", value);
}

- (NSInteger)accessibilityColumnCount {
    NSNumber *value = DarlingAXValue(self, @"accessibilityColumnCount");
    return value != nil ? (NSInteger)[value integerValue] : 0;
}

- (void)setAccessibilityColumnCount:(NSInteger)value {
    DarlingAXSetValue(self, @"accessibilityColumnCount", [NSNumber numberWithInteger: (NSInteger)value]);
}

- (NSInteger)accessibilityRowCount {
    NSNumber *value = DarlingAXValue(self, @"accessibilityRowCount");
    return value != nil ? (NSInteger)[value integerValue] : 0;
}

- (void)setAccessibilityRowCount:(NSInteger)value {
    DarlingAXSetValue(self, @"accessibilityRowCount", [NSNumber numberWithInteger: (NSInteger)value]);
}

- (NSInteger)accessibilityIndex {
    NSNumber *value = DarlingAXValue(self, @"accessibilityIndex");
    return value != nil ? (NSInteger)[value integerValue] : 0;
}

- (void)setAccessibilityIndex:(NSInteger)value {
    DarlingAXSetValue(self, @"accessibilityIndex", [NSNumber numberWithInteger: (NSInteger)value]);
}

- (NSArray *)accessibilityColumns {
    return DarlingAXValue(self, @"accessibilityColumns");
}

- (void)setAccessibilityColumns:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilityColumns", value);
}

- (NSArray *)accessibilityRows {
    return DarlingAXValue(self, @"accessibilityRows");
}

- (void)setAccessibilityRows:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilityRows", value);
}

- (NSArray *)accessibilityVisibleRows {
    return DarlingAXValue(self, @"accessibilityVisibleRows");
}

- (void)setAccessibilityVisibleRows:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilityVisibleRows", value);
}

- (NSArray *)accessibilitySelectedRows {
    return DarlingAXValue(self, @"accessibilitySelectedRows");
}

- (void)setAccessibilitySelectedRows:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilitySelectedRows", value);
}

- (NSArray *)accessibilityVisibleColumns {
    return DarlingAXValue(self, @"accessibilityVisibleColumns");
}

- (void)setAccessibilityVisibleColumns:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilityVisibleColumns", value);
}

- (NSArray *)accessibilitySelectedColumns {
    return DarlingAXValue(self, @"accessibilitySelectedColumns");
}

- (void)setAccessibilitySelectedColumns:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilitySelectedColumns", value);
}

- (NSAccessibilitySortDirection)accessibilitySortDirection {
    NSNumber *value = DarlingAXValue(self, @"accessibilitySortDirection");
    return value != nil ? [value integerValue] : 0;
}

- (void)setAccessibilitySortDirection:(NSAccessibilitySortDirection)value {
    DarlingAXSetValue(self, @"accessibilitySortDirection", [NSNumber numberWithInteger: (NSInteger)value]);
}

- (NSArray *)accessibilityRowHeaderUIElements {
    return DarlingAXValue(self, @"accessibilityRowHeaderUIElements");
}

- (void)setAccessibilityRowHeaderUIElements:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilityRowHeaderUIElements", value);
}

- (NSArray *)accessibilitySelectedCells {
    return DarlingAXValue(self, @"accessibilitySelectedCells");
}

- (void)setAccessibilitySelectedCells:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilitySelectedCells", value);
}

- (NSArray *)accessibilityVisibleCells {
    return DarlingAXValue(self, @"accessibilityVisibleCells");
}

- (void)setAccessibilityVisibleCells:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilityVisibleCells", value);
}

- (NSArray *)accessibilityColumnHeaderUIElements {
    return DarlingAXValue(self, @"accessibilityColumnHeaderUIElements");
}

- (void)setAccessibilityColumnHeaderUIElements:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilityColumnHeaderUIElements", value);
}

- (NSRange)accessibilityRowIndexRange {
    NSValue *value = DarlingAXValue(self, @"accessibilityRowIndexRange");
    return value != nil ? [value rangeValue] : NSMakeRange(0, 0);
}

- (void)setAccessibilityRowIndexRange:(NSRange)value {
    DarlingAXSetValue(self, @"accessibilityRowIndexRange", [NSValue valueWithRange: value]);
}

- (NSRange)accessibilityColumnIndexRange {
    NSValue *value = DarlingAXValue(self, @"accessibilityColumnIndexRange");
    return value != nil ? [value rangeValue] : NSMakeRange(0, 0);
}

- (void)setAccessibilityColumnIndexRange:(NSRange)value {
    DarlingAXSetValue(self, @"accessibilityColumnIndexRange", [NSValue valueWithRange: value]);
}

- (NSInteger)accessibilityInsertionPointLineNumber {
    NSNumber *value = DarlingAXValue(self, @"accessibilityInsertionPointLineNumber");
    return value != nil ? (NSInteger)[value integerValue] : 0;
}

- (void)setAccessibilityInsertionPointLineNumber:(NSInteger)value {
    DarlingAXSetValue(self, @"accessibilityInsertionPointLineNumber", [NSNumber numberWithInteger: (NSInteger)value]);
}

- (NSRange)accessibilitySharedCharacterRange {
    NSValue *value = DarlingAXValue(self, @"accessibilitySharedCharacterRange");
    return value != nil ? [value rangeValue] : NSMakeRange(0, 0);
}

- (void)setAccessibilitySharedCharacterRange:(NSRange)value {
    DarlingAXSetValue(self, @"accessibilitySharedCharacterRange", [NSValue valueWithRange: value]);
}

- (NSArray *)accessibilitySharedTextUIElements {
    return DarlingAXValue(self, @"accessibilitySharedTextUIElements");
}

- (void)setAccessibilitySharedTextUIElements:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilitySharedTextUIElements", value);
}

- (NSRange)accessibilityVisibleCharacterRange {
    NSValue *value = DarlingAXValue(self, @"accessibilityVisibleCharacterRange");
    return value != nil ? [value rangeValue] : NSMakeRange(0, 0);
}

- (void)setAccessibilityVisibleCharacterRange:(NSRange)value {
    DarlingAXSetValue(self, @"accessibilityVisibleCharacterRange", [NSValue valueWithRange: value]);
}

- (NSInteger)accessibilityNumberOfCharacters {
    NSNumber *value = DarlingAXValue(self, @"accessibilityNumberOfCharacters");
    return value != nil ? (NSInteger)[value integerValue] : 0;
}

- (void)setAccessibilityNumberOfCharacters:(NSInteger)value {
    DarlingAXSetValue(self, @"accessibilityNumberOfCharacters", [NSNumber numberWithInteger: (NSInteger)value]);
}

- (NSString *)accessibilitySelectedText {
    return DarlingAXValue(self, @"accessibilitySelectedText");
}

- (void)setAccessibilitySelectedText:(NSString *)value {
    DarlingAXSetValue(self, @"accessibilitySelectedText", value);
}

- (NSRange)accessibilitySelectedTextRange {
    NSValue *value = DarlingAXValue(self, @"accessibilitySelectedTextRange");
    return value != nil ? [value rangeValue] : NSMakeRange(0, 0);
}

- (void)setAccessibilitySelectedTextRange:(NSRange)value {
    DarlingAXSetValue(self, @"accessibilitySelectedTextRange", [NSValue valueWithRange: value]);
}

- (NSArray *)accessibilitySelectedTextRanges {
    return DarlingAXValue(self, @"accessibilitySelectedTextRanges");
}

- (void)setAccessibilitySelectedTextRanges:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilitySelectedTextRanges", value);
}

- (id)accessibilityToolbarButton {
    return DarlingAXValue(self, @"accessibilityToolbarButton");
}

- (void)setAccessibilityToolbarButton:(id)value {
    DarlingAXSetValue(self, @"accessibilityToolbarButton", value);
}

- (BOOL)isAccessibilityModal {
    NSNumber *value = DarlingAXValue(self, @"accessibilityModal");
    return value != nil ? [value boolValue] : NO;
}

- (void)setAccessibilityModal:(BOOL)value {
    DarlingAXSetValue(self, @"accessibilityModal", [NSNumber numberWithBool: value]);
}

- (id)accessibilityProxy {
    return DarlingAXValue(self, @"accessibilityProxy");
}

- (void)setAccessibilityProxy:(id)value {
    DarlingAXSetValue(self, @"accessibilityProxy", value);
}

- (BOOL)isAccessibilityMain {
    NSNumber *value = DarlingAXValue(self, @"accessibilityMain");
    return value != nil ? [value boolValue] : NO;
}

- (void)setAccessibilityMain:(BOOL)value {
    DarlingAXSetValue(self, @"accessibilityMain", [NSNumber numberWithBool: value]);
}

- (id)accessibilityFullScreenButton {
    return DarlingAXValue(self, @"accessibilityFullScreenButton");
}

- (void)setAccessibilityFullScreenButton:(id)value {
    DarlingAXSetValue(self, @"accessibilityFullScreenButton", value);
}

- (id)accessibilityGrowArea {
    return DarlingAXValue(self, @"accessibilityGrowArea");
}

- (void)setAccessibilityGrowArea:(id)value {
    DarlingAXSetValue(self, @"accessibilityGrowArea", value);
}

- (NSString *)accessibilityDocument {
    return DarlingAXValue(self, @"accessibilityDocument");
}

- (void)setAccessibilityDocument:(NSString *)value {
    DarlingAXSetValue(self, @"accessibilityDocument", value);
}

- (id)accessibilityDefaultButton {
    return DarlingAXValue(self, @"accessibilityDefaultButton");
}

- (void)setAccessibilityDefaultButton:(id)value {
    DarlingAXSetValue(self, @"accessibilityDefaultButton", value);
}

- (id)accessibilityCloseButton {
    return DarlingAXValue(self, @"accessibilityCloseButton");
}

- (void)setAccessibilityCloseButton:(id)value {
    DarlingAXSetValue(self, @"accessibilityCloseButton", value);
}

- (id)accessibilityZoomButton {
    return DarlingAXValue(self, @"accessibilityZoomButton");
}

- (void)setAccessibilityZoomButton:(id)value {
    DarlingAXSetValue(self, @"accessibilityZoomButton", value);
}

- (id)accessibilityMinimizeButton {
    return DarlingAXValue(self, @"accessibilityMinimizeButton");
}

- (void)setAccessibilityMinimizeButton:(id)value {
    DarlingAXSetValue(self, @"accessibilityMinimizeButton", value);
}

- (BOOL)isAccessibilityMinimized {
    NSNumber *value = DarlingAXValue(self, @"accessibilityMinimized");
    return value != nil ? [value boolValue] : NO;
}

- (void)setAccessibilityMinimized:(BOOL)value {
    DarlingAXSetValue(self, @"accessibilityMinimized", [NSNumber numberWithBool: value]);
}

- (NSArray *)accessibilityCustomActions {
    return DarlingAXValue(self, @"accessibilityCustomActions");
}

- (void)setAccessibilityCustomActions:(NSArray *)value {
    DarlingAXSetValue(self, @"accessibilityCustomActions", value);
}

- (NSPoint)accessibilityLayoutPointForScreenPoint:(NSPoint)point {
    (void)point;
    return NSZeroPoint;
}

- (NSSize)accessibilityLayoutSizeForScreenSize:(NSSize)size {
    (void)size;
    return NSZeroSize;
}

- (NSPoint)accessibilityScreenPointForLayoutPoint:(NSPoint)point {
    (void)point;
    return NSZeroPoint;
}

- (NSSize)accessibilityScreenSizeForLayoutSize:(NSSize)size {
    (void)size;
    return NSZeroSize;
}

- (id)accessibilityCellForColumn:(NSInteger)column row:(NSInteger)row {
    (void)column; (void)row;
    return nil;
}

- (NSAttributedString *)accessibilityAttributedStringForRange:(NSRange)range {
    (void)range;
    return nil;
}

- (NSRange)accessibilityRangeForLine:(NSInteger)line {
    (void)line;
    return NSMakeRange(0, 0);
}

- (NSString *)accessibilityStringForRange:(NSRange)range {
    (void)range;
    return nil;
}

- (NSRange)accessibilityRangeForPosition:(NSPoint)point {
    (void)point;
    return NSMakeRange(0, 0);
}

- (NSRange)accessibilityRangeForIndex:(NSInteger)index {
    (void)index;
    return NSMakeRange(0, 0);
}

- (NSRect)accessibilityFrameForRange:(NSRange)range {
    (void)range;
    return NSZeroRect;
}

- (NSData *)accessibilityRTFForRange:(NSRange)range {
    (void)range;
    return nil;
}

- (NSRange)accessibilityStyleRangeForIndex:(NSInteger)index {
    (void)index;
    return NSMakeRange(0, 0);
}

- (NSInteger)accessibilityLineForIndex:(NSInteger)index {
    (void)index;
    return 0;
}

- (BOOL)isAccessibilitySelectorAllowed:(SEL)selector {
    (void)selector;
    return YES;
}

- (BOOL)accessibilityPerformCancel {
    return NO;
}

- (BOOL)accessibilityPerformConfirm {
    return NO;
}

- (BOOL)accessibilityPerformDecrement {
    return NO;
}

- (BOOL)accessibilityPerformDelete {
    return NO;
}

- (BOOL)accessibilityPerformIncrement {
    return NO;
}

- (BOOL)accessibilityPerformPick {
    return NO;
}

- (BOOL)accessibilityPerformPress {
    return NO;
}

- (BOOL)accessibilityPerformRaise {
    return NO;
}

- (BOOL)accessibilityPerformShowAlternateUI {
    return NO;
}

- (BOOL)accessibilityPerformShowDefaultUI {
    return NO;
}

- (BOOL)accessibilityPerformShowMenu {
    return NO;
}

@end
