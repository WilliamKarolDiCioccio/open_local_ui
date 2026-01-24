import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @abortModelRemovalSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Abort model removal'**
  String get abortModelRemovalSnackBar;

  /// No description provided for @abortSessionRemovalSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Abort session removal'**
  String get abortSessionRemovalSnackBar;

  /// No description provided for @aboutPageContributorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contributors'**
  String get aboutPageContributorsTitle;

  /// No description provided for @aboutPageCopyrightNotice.
  ///
  /// In en, this message translates to:
  /// **'© 2024 William Karol Di Cioccio'**
  String get aboutPageCopyrightNotice;

  /// No description provided for @aboutPageDiscoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover more'**
  String get aboutPageDiscoverTitle;

  /// No description provided for @aboutPagePoweredByTitle.
  ///
  /// In en, this message translates to:
  /// **'Powered by'**
  String get aboutPagePoweredByTitle;

  /// No description provided for @aboutPageSocialButtonContributeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Contribute'**
  String get aboutPageSocialButtonContributeTooltip;

  /// No description provided for @aboutPageSocialButtonJoinServerTooltip.
  ///
  /// In en, this message translates to:
  /// **'Join server'**
  String get aboutPageSocialButtonJoinServerTooltip;

  /// No description provided for @aboutPageSocialButtonWatchTrailerTooltip.
  ///
  /// In en, this message translates to:
  /// **'Watch trailer'**
  String get aboutPageSocialButtonWatchTrailerTooltip;

  /// No description provided for @aboutPageVisitProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Visit profile'**
  String get aboutPageVisitProfileTooltip;

  /// No description provided for @activateButtonShared.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activateButtonShared;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MyApp'**
  String get appTitle;

  /// No description provided for @attachFilesDialogAllowedFormats.
  ///
  /// In en, this message translates to:
  /// **'Allowed formats: {formats}'**
  String attachFilesDialogAllowedFormats(String formats);

  /// No description provided for @attachFilesDialogBrowseFilesButton.
  ///
  /// In en, this message translates to:
  /// **'Browse files'**
  String get attachFilesDialogBrowseFilesButton;

  /// No description provided for @attachFilesDialogDropFilesText.
  ///
  /// In en, this message translates to:
  /// **'Drop files here'**
  String get attachFilesDialogDropFilesText;

  /// No description provided for @cancelButtonShared.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButtonShared;

  /// No description provided for @changelogButton.
  ///
  /// In en, this message translates to:
  /// **'Changelog'**
  String get changelogButton;

  /// No description provided for @chatAttachFilesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Attach files'**
  String get chatAttachFilesTooltip;

  /// No description provided for @chatCancelEditButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel editing'**
  String get chatCancelEditButton;

  /// No description provided for @chatCancelGenerationTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cancel generation'**
  String get chatCancelGenerationTooltip;

  /// No description provided for @chatCopyMessageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy message'**
  String get chatCopyMessageTooltip;

  /// No description provided for @chatDetachFilesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Detach files'**
  String get chatDetachFilesTooltip;

  /// No description provided for @chatEditFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get chatEditFieldHint;

  /// No description provided for @chatEditMessageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit message'**
  String get chatEditMessageTooltip;

  /// No description provided for @chatInputFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get chatInputFieldHint;

  /// No description provided for @chatReadAloudTooltip.
  ///
  /// In en, this message translates to:
  /// **'Read aloud'**
  String get chatReadAloudTooltip;

  /// No description provided for @chatRefreshSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Refresh suggestions'**
  String get chatRefreshSuggestions;

  /// No description provided for @chatRegenerateMessageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Regenerate message'**
  String get chatRegenerateMessageTooltip;

  /// No description provided for @chatResendMessageButton.
  ///
  /// In en, this message translates to:
  /// **'Resend message'**
  String get chatResendMessageButton;

  /// No description provided for @chatSendTooltip.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get chatSendTooltip;

  /// No description provided for @chatStatisticsDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration: {duration} ms'**
  String chatStatisticsDuration(String duration);

  /// No description provided for @chatStatisticsSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed: {speed} tokens/s'**
  String chatStatisticsSpeed(String speed);

  /// No description provided for @chatStatisticsTokens.
  ///
  /// In en, this message translates to:
  /// **'Tokens: {tokens}'**
  String chatStatisticsTokens(int tokens);

  /// No description provided for @chatSuggestionsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Want some suggestions?'**
  String get chatSuggestionsPrompt;

  /// No description provided for @chatSystemSender.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get chatSystemSender;

  /// No description provided for @chatTitleEditHint.
  ///
  /// In en, this message translates to:
  /// **'Type a title...'**
  String get chatTitleEditHint;

  /// No description provided for @chatToolbarDocsSearchOption.
  ///
  /// In en, this message translates to:
  /// **'Docs search:'**
  String get chatToolbarDocsSearchOption;

  /// No description provided for @chatToolbarModelSelectorHint.
  ///
  /// In en, this message translates to:
  /// **'Select model'**
  String get chatToolbarModelSelectorHint;

  /// No description provided for @chatToolbarNewSessionButton.
  ///
  /// In en, this message translates to:
  /// **'New session'**
  String get chatToolbarNewSessionButton;

  /// No description provided for @chatToolbarWebSearchOption.
  ///
  /// In en, this message translates to:
  /// **'Web search:'**
  String get chatToolbarWebSearchOption;

  /// No description provided for @chatUserSender.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get chatUserSender;

  /// No description provided for @chatWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get chatWelcomeMessage;

  /// No description provided for @checkingForUpdatesDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates'**
  String get checkingForUpdatesDialogTitle;

  /// No description provided for @clickToDownloadLatestAppVersionSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Click here to download the latest version'**
  String get clickToDownloadLatestAppVersionSnackBar;

  /// No description provided for @clickToDownloadLatestOllamaVersionSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Click here to download the latest version'**
  String get clickToDownloadLatestOllamaVersionSnackBar;

  /// No description provided for @closeButtonShared.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButtonShared;

  /// No description provided for @codeCopiedSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get codeCopiedSnackBar;

  /// No description provided for @colorPickerDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a color'**
  String get colorPickerDialogTitle;

  /// No description provided for @concurrencyLimit.
  ///
  /// In en, this message translates to:
  /// **'Concurrency Limit'**
  String get concurrencyLimit;

  /// No description provided for @copyButtonShared.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyButtonShared;

  /// No description provided for @createButtonShared.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createButtonShared;

  /// No description provided for @createModelDialogGuideText1.
  ///
  /// In en, this message translates to:
  /// **'Select the model to use:'**
  String get createModelDialogGuideText1;

  /// No description provided for @createModelDialogGuideText2.
  ///
  /// In en, this message translates to:
  /// **'Enter the name of the model to create:'**
  String get createModelDialogGuideText2;

  /// No description provided for @createModelDialogGuideText3.
  ///
  /// In en, this message translates to:
  /// **'Optionally, write a model file:'**
  String get createModelDialogGuideText3;

  /// No description provided for @createModelDialogModelFileHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the model file...'**
  String get createModelDialogModelFileHint;

  /// No description provided for @createModelDialogModelFileLabel.
  ///
  /// In en, this message translates to:
  /// **'Model file'**
  String get createModelDialogModelFileLabel;

  /// No description provided for @createModelDialogModelNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the model name...'**
  String get createModelDialogModelNameHint;

  /// No description provided for @createModelDialogModelNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Model name'**
  String get createModelDialogModelNameLabel;

  /// No description provided for @createModelDialogModelSelectorHint.
  ///
  /// In en, this message translates to:
  /// **'Select model'**
  String get createModelDialogModelSelectorHint;

  /// No description provided for @createModelDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Create model'**
  String get createModelDialogTitle;

  /// No description provided for @createdAtTextShared.
  ///
  /// In en, this message translates to:
  /// **'Created at: {createdAt}'**
  String createdAtTextShared(String createdAt);

  /// No description provided for @dashboardAboutButton.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get dashboardAboutButton;

  /// No description provided for @dashboardChatButton.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get dashboardChatButton;

  /// No description provided for @dashboardHomeButton.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get dashboardHomeButton;

  /// No description provided for @dashboardInventoryButton.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get dashboardInventoryButton;

  /// No description provided for @dashboardMarketButton.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get dashboardMarketButton;

  /// No description provided for @dashboardSessionsButton.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get dashboardSessionsButton;

  /// No description provided for @dashboardSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get dashboardSettingsButton;

  /// No description provided for @devicePluggedInSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Device plugged in. Power delivery increased.'**
  String get devicePluggedInSnackBar;

  /// No description provided for @deviceUnpluggedSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Device unplugged. Power delivery reduced.'**
  String get deviceUnpluggedSnackBar;

  /// No description provided for @dialogAttachButton.
  ///
  /// In en, this message translates to:
  /// **'Attach'**
  String get dialogAttachButton;

  /// No description provided for @dialogCancelButtonShared.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancelButtonShared;

  /// No description provided for @dialogCloseButtonShared.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get dialogCloseButtonShared;

  /// No description provided for @dialogConfirmButtonShared.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get dialogConfirmButtonShared;

  /// No description provided for @dialogContinueInBackgroundButtonShared.
  ///
  /// In en, this message translates to:
  /// **'Continue in background'**
  String get dialogContinueInBackgroundButtonShared;

  /// No description provided for @dialogCreateButtonShared.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get dialogCreateButtonShared;

  /// No description provided for @dialogRemoveButton.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get dialogRemoveButton;

  /// No description provided for @dialogSkipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get dialogSkipButton;

  /// No description provided for @dialogStartButtonShared.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get dialogStartButtonShared;

  /// No description provided for @dialogUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get dialogUpdateButton;

  /// No description provided for @digestCopiedSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Digest copied to clipboard'**
  String get digestCopiedSnackBar;

  /// No description provided for @enableDocsSearch.
  ///
  /// In en, this message translates to:
  /// **'Docs Search'**
  String get enableDocsSearch;

  /// No description provided for @enableWebSearch.
  ///
  /// In en, this message translates to:
  /// **'Web Search'**
  String get enableWebSearch;

  /// No description provided for @enteringCriticalSectionSnackBar.
  ///
  /// In en, this message translates to:
  /// **'You\'re entering critical section. Tap if you want to continue'**
  String get enteringCriticalSectionSnackBar;

  /// No description provided for @errorRetrievingSystemInfoSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Error retrieving system info'**
  String get errorRetrievingSystemInfoSnackBar;

  /// No description provided for @f16KV.
  ///
  /// In en, this message translates to:
  /// **'F16KV'**
  String get f16KV;

  /// No description provided for @failedToCreateFolderSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Failed to create folder'**
  String get failedToCreateFolderSnackBar;

  /// No description provided for @failedToCreateModelSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Failed to create model'**
  String get failedToCreateModelSnackBar;

  /// No description provided for @failedToPullModelSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Failed to pull model'**
  String get failedToPullModelSnackBar;

  /// No description provided for @failedToPushModelSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Failed to push model'**
  String get failedToPushModelSnackBar;

  /// No description provided for @failedToShareProfileSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Failed to share profile'**
  String get failedToShareProfileSnackBar;

  /// No description provided for @failedToShareSessionSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Failed to share session'**
  String get failedToShareSessionSnackBar;

  /// No description provided for @feedbackButton.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackButton;

  /// No description provided for @folderCreatedSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Folder created'**
  String get folderCreatedSnackBar;

  /// No description provided for @frequencyPenalty.
  ///
  /// In en, this message translates to:
  /// **'Frequency Penalty'**
  String get frequencyPenalty;

  /// No description provided for @importModelDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Import model'**
  String get importModelDialogTitle;

  /// No description provided for @inventoryPageCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get inventoryPageCreateButton;

  /// No description provided for @inventoryPageDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete model'**
  String get inventoryPageDeleteButton;

  /// No description provided for @inventoryPageDeleteDialogText.
  ///
  /// In en, this message translates to:
  /// **'This will delete {modelName}. Do you confirm?'**
  String inventoryPageDeleteDialogText(String modelName);

  /// No description provided for @inventoryPageDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete model'**
  String get inventoryPageDeleteDialogTitle;

  /// No description provided for @inventoryPageDetailsButton.
  ///
  /// In en, this message translates to:
  /// **'View model details'**
  String get inventoryPageDetailsButton;

  /// No description provided for @inventoryPageImportButton.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get inventoryPageImportButton;

  /// No description provided for @inventoryPagePushButton.
  ///
  /// In en, this message translates to:
  /// **'Push'**
  String get inventoryPagePushButton;

  /// No description provided for @inventoryPageRefreshButton.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get inventoryPageRefreshButton;

  /// No description provided for @inventoryPageSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Open model settings'**
  String get inventoryPageSettingsButton;

  /// No description provided for @inventoryPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventoryPageTitle;

  /// No description provided for @keepAlive.
  ///
  /// In en, this message translates to:
  /// **'Keep Alive'**
  String get keepAlive;

  /// No description provided for @licenseButton.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get licenseButton;

  /// No description provided for @listFiltersSortByLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get listFiltersSortByLabel;

  /// No description provided for @listFiltersSortOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'In order'**
  String get listFiltersSortOrderLabel;

  /// No description provided for @llmMistakesWarningText.
  ///
  /// In en, this message translates to:
  /// **'LLMs can make mistakes. Please check important information.'**
  String get llmMistakesWarningText;

  /// No description provided for @logitsAll.
  ///
  /// In en, this message translates to:
  /// **'Logits All'**
  String get logitsAll;

  /// No description provided for @lowVram.
  ///
  /// In en, this message translates to:
  /// **'Low VRAM'**
  String get lowVram;

  /// No description provided for @mainGpu.
  ///
  /// In en, this message translates to:
  /// **'Main GPU'**
  String get mainGpu;

  /// No description provided for @markdownCopyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy markdown'**
  String get markdownCopyTooltip;

  /// No description provided for @markdownLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language: {language}'**
  String markdownLanguageLabel(String language);

  /// No description provided for @marketPageCapabilitiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Capabilities'**
  String get marketPageCapabilitiesLabel;

  /// No description provided for @marketPagePullButton.
  ///
  /// In en, this message translates to:
  /// **'Pull'**
  String get marketPagePullButton;

  /// No description provided for @marketPageReleasesLabel.
  ///
  /// In en, this message translates to:
  /// **'Releases'**
  String get marketPageReleasesLabel;

  /// No description provided for @marketPageSearchFiltersButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search filters'**
  String get marketPageSearchFiltersButtonTooltip;

  /// No description provided for @marketPageSearchResultsLabel.
  ///
  /// In en, this message translates to:
  /// **'{totalResults} results found'**
  String marketPageSearchResultsLabel(int totalResults);

  /// No description provided for @marketPageSearchTextFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Search models by name...'**
  String get marketPageSearchTextFieldHint;

  /// No description provided for @marketPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get marketPageTitle;

  /// No description provided for @marketPageViewMoreButton.
  ///
  /// In en, this message translates to:
  /// **'View more'**
  String get marketPageViewMoreButton;

  /// No description provided for @marketPageViewMoreButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Redirects to {url}'**
  String marketPageViewMoreButtonTooltip(String url);

  /// No description provided for @messageCopiedSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Message copied to clipboard'**
  String get messageCopiedSnackBar;

  /// No description provided for @mirostat.
  ///
  /// In en, this message translates to:
  /// **'Microstat'**
  String get mirostat;

  /// No description provided for @mirostatEta.
  ///
  /// In en, this message translates to:
  /// **'Microstat ETA'**
  String get mirostatEta;

  /// No description provided for @mirostatTau.
  ///
  /// In en, this message translates to:
  /// **'Microstat TAU'**
  String get mirostatTau;

  /// No description provided for @modelCreatedSuccessfullySnackBar.
  ///
  /// In en, this message translates to:
  /// **'Model created successfully'**
  String get modelCreatedSuccessfullySnackBar;

  /// No description provided for @modelDetailsDigestText.
  ///
  /// In en, this message translates to:
  /// **'Digest: {digest}'**
  String modelDetailsDigestText(String digest);

  /// No description provided for @modelDetailsFamilyText.
  ///
  /// In en, this message translates to:
  /// **'Family: {family}'**
  String modelDetailsFamilyText(String family);

  /// No description provided for @modelDetailsFormatText.
  ///
  /// In en, this message translates to:
  /// **'Format: {format}'**
  String modelDetailsFormatText(String format);

  /// No description provided for @modelDetailsParametersSizeText.
  ///
  /// In en, this message translates to:
  /// **'Parameters: {parametersSize} B'**
  String modelDetailsParametersSizeText(String parametersSize);

  /// No description provided for @modelDetailsQuantizationLevelText.
  ///
  /// In en, this message translates to:
  /// **'Quantization: {quantizationLevel}'**
  String modelDetailsQuantizationLevelText(String quantizationLevel);

  /// No description provided for @modelDetailsSizeText.
  ///
  /// In en, this message translates to:
  /// **'Size: {size} GB'**
  String modelDetailsSizeText(String size);

  /// No description provided for @modelDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'{modelName} details'**
  String modelDetailsTitle(String modelName);

  /// No description provided for @modelGeneralSettingsLabel.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get modelGeneralSettingsLabel;

  /// No description provided for @modelIsGeneratingSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Model is generating'**
  String get modelIsGeneratingSnackBar;

  /// No description provided for @modelMiscSettingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Miscellaneous Settings'**
  String get modelMiscSettingsLabel;

  /// No description provided for @modelPenaltySettingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Penalty Settings'**
  String get modelPenaltySettingsLabel;

  /// No description provided for @modelPerformanceSettingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Performance Settings'**
  String get modelPerformanceSettingsLabel;

  /// No description provided for @modelPulledSuccessfullySnackBar.
  ///
  /// In en, this message translates to:
  /// **'Model pulled successfully'**
  String get modelPulledSuccessfullySnackBar;

  /// No description provided for @modelPushedSuccessfullySnackBar.
  ///
  /// In en, this message translates to:
  /// **'Model pushed successfully'**
  String get modelPushedSuccessfullySnackBar;

  /// No description provided for @modelSearchFiltersDialogSelectedCapabilitiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Capabilities:'**
  String get modelSearchFiltersDialogSelectedCapabilitiesLabel;

  /// No description provided for @modelSearchFiltersDialogSelectedMaxResultsLabel.
  ///
  /// In en, this message translates to:
  /// **'Max results: {maxResults}'**
  String modelSearchFiltersDialogSelectedMaxResultsLabel(int maxResults);

  /// No description provided for @modelSearchFiltersDialogSelectedMaxSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Max size: {maxSize} GB'**
  String modelSearchFiltersDialogSelectedMaxSizeLabel(String maxSize);

  /// No description provided for @modelSearchFiltersDialogSelectedMinSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Min size: {minSize} GB'**
  String modelSearchFiltersDialogSelectedMinSizeLabel(String minSize);

  /// No description provided for @modelSearchFiltersDialogSelectedOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Order by:'**
  String get modelSearchFiltersDialogSelectedOrderLabel;

  /// No description provided for @modelSearchFiltersDialogSelectedSortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort by:'**
  String get modelSearchFiltersDialogSelectedSortLabel;

  /// No description provided for @modelSearchFiltersDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Search filters'**
  String get modelSearchFiltersDialogTitle;

  /// No description provided for @modelSettingsDialogClearProfilesButton.
  ///
  /// In en, this message translates to:
  /// **'Clear profiles'**
  String get modelSettingsDialogClearProfilesButton;

  /// No description provided for @modelSettingsDialogClearProfilesText.
  ///
  /// In en, this message translates to:
  /// **'This will clear all profiles. Do you confirm?'**
  String get modelSettingsDialogClearProfilesText;

  /// No description provided for @modelSettingsDialogCreateDialogLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile name'**
  String get modelSettingsDialogCreateDialogLabel;

  /// No description provided for @modelSettingsDialogCreateDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Create profile'**
  String get modelSettingsDialogCreateDialogTitle;

  /// No description provided for @modelSettingsDialogDeleteDialogText.
  ///
  /// In en, this message translates to:
  /// **'This will delete {profileName}. Do you confirm?'**
  String modelSettingsDialogDeleteDialogText(String profileName);

  /// No description provided for @modelSettingsDialogDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete profile'**
  String get modelSettingsDialogDeleteDialogTitle;

  /// No description provided for @modelSettingsDialogEditDialogLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile name'**
  String get modelSettingsDialogEditDialogLabel;

  /// No description provided for @modelSettingsDialogEditDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get modelSettingsDialogEditDialogTitle;

  /// No description provided for @modelSpecificSettingsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'{modelName} settings profiles'**
  String modelSpecificSettingsDialogTitle(String modelName);

  /// No description provided for @modifiedAtTextShared.
  ///
  /// In en, this message translates to:
  /// **'Modified at: {modifiedAt}'**
  String modifiedAtTextShared(String modifiedAt);

  /// No description provided for @moreOptionsButton.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptionsButton;

  /// No description provided for @noModelsAvailableSnackBar.
  ///
  /// In en, this message translates to:
  /// **'No models available'**
  String get noModelsAvailableSnackBar;

  /// No description provided for @noNeedToCreateSessionSnackBar.
  ///
  /// In en, this message translates to:
  /// **'No need to create a new session'**
  String get noNeedToCreateSessionSnackBar;

  /// No description provided for @noUpdatesAvailableDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'No updates available'**
  String get noUpdatesAvailableDialogTitle;

  /// No description provided for @nothingToSynthesizeSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Nothing to synthesize'**
  String get nothingToSynthesizeSnackBar;

  /// No description provided for @numBatch.
  ///
  /// In en, this message translates to:
  /// **'Num. Batch'**
  String get numBatch;

  /// No description provided for @numCtx.
  ///
  /// In en, this message translates to:
  /// **'Context Window Size'**
  String get numCtx;

  /// No description provided for @numGpu.
  ///
  /// In en, this message translates to:
  /// **'Num. GPU'**
  String get numGpu;

  /// No description provided for @numKeep.
  ///
  /// In en, this message translates to:
  /// **'Num. Keep'**
  String get numKeep;

  /// No description provided for @numPredict.
  ///
  /// In en, this message translates to:
  /// **'Num. Predict'**
  String get numPredict;

  /// No description provided for @numThread.
  ///
  /// In en, this message translates to:
  /// **'Num. Threads'**
  String get numThread;

  /// No description provided for @numa.
  ///
  /// In en, this message translates to:
  /// **'NUMA'**
  String get numa;

  /// No description provided for @offlineWarningTextShared.
  ///
  /// In en, this message translates to:
  /// **'You are offline'**
  String get offlineWarningTextShared;

  /// No description provided for @ollamaDisabledGPUWarningSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Disabling GPU is harmful for performance'**
  String get ollamaDisabledGPUWarningSnackBar;

  /// No description provided for @penalizeNewline.
  ///
  /// In en, this message translates to:
  /// **'Penalize Newline'**
  String get penalizeNewline;

  /// No description provided for @presencePenalty.
  ///
  /// In en, this message translates to:
  /// **'Presence Penalty'**
  String get presencePenalty;

  /// No description provided for @privacyButton.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyButton;

  /// No description provided for @profileSharedSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Profile shared'**
  String get profileSharedSnackBar;

  /// No description provided for @profilesPageDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete profile'**
  String get profilesPageDeleteButton;

  /// No description provided for @profilesPageShareButton.
  ///
  /// In en, this message translates to:
  /// **'Share profile'**
  String get profilesPageShareButton;

  /// No description provided for @progressBarStatusWithStepsText.
  ///
  /// In en, this message translates to:
  /// **'Status: {status} - Step {completedSteps} of {totalSteps}'**
  String progressBarStatusWithStepsText(
    String status,
    int totalSteps,
    int completedSteps,
  );

  /// No description provided for @progressBarStatusWithTimeText.
  ///
  /// In en, this message translates to:
  /// **'Status: {status} - Remaining time: {hours}:{minutes}:{seconds}'**
  String progressBarStatusWithTimeText(
    String status,
    String hours,
    String minutes,
    String seconds,
  );

  /// No description provided for @pullModelDialogGuideText.
  ///
  /// In en, this message translates to:
  /// **'Please type the release of the model to pull:'**
  String get pullModelDialogGuideText;

  /// No description provided for @pullModelDialogModelNameHint.
  ///
  /// In en, this message translates to:
  /// **'Type model name...'**
  String get pullModelDialogModelNameHint;

  /// No description provided for @pullModelDialogModelNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Model name'**
  String get pullModelDialogModelNameLabel;

  /// No description provided for @pullModelDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Pull model'**
  String get pullModelDialogTitle;

  /// No description provided for @pushModelDialogGuideText.
  ///
  /// In en, this message translates to:
  /// **'Please select the model to push:'**
  String get pushModelDialogGuideText;

  /// No description provided for @pushModelDialogModelSelectorHint.
  ///
  /// In en, this message translates to:
  /// **'Select model'**
  String get pushModelDialogModelSelectorHint;

  /// No description provided for @pushModelDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Push model'**
  String get pushModelDialogTitle;

  /// No description provided for @redoButtonShared.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redoButtonShared;

  /// No description provided for @repeatLastN.
  ///
  /// In en, this message translates to:
  /// **'Repeat Last N'**
  String get repeatLastN;

  /// No description provided for @repeatPenalty.
  ///
  /// In en, this message translates to:
  /// **'Repeat Penalty'**
  String get repeatPenalty;

  /// No description provided for @resetToDefaultsButtonShared.
  ///
  /// In en, this message translates to:
  /// **'Reset to defaults'**
  String get resetToDefaultsButtonShared;

  /// No description provided for @saveButtonShared.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButtonShared;

  /// No description provided for @searchButtonShared.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchButtonShared;

  /// No description provided for @seed.
  ///
  /// In en, this message translates to:
  /// **'Seed'**
  String get seed;

  /// No description provided for @sessionSharedSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Session shared'**
  String get sessionSharedSnackBar;

  /// No description provided for @sessionsPageClearDialogText.
  ///
  /// In en, this message translates to:
  /// **'This will clear all sessions. Do you confirm?'**
  String get sessionsPageClearDialogText;

  /// No description provided for @sessionsPageClearDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear sessions'**
  String get sessionsPageClearDialogTitle;

  /// No description provided for @sessionsPageClearSessionsButton.
  ///
  /// In en, this message translates to:
  /// **'Clear sessions'**
  String get sessionsPageClearSessionsButton;

  /// No description provided for @sessionsPageCreateFolderButton.
  ///
  /// In en, this message translates to:
  /// **'Create folder'**
  String get sessionsPageCreateFolderButton;

  /// No description provided for @sessionsPageDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete session'**
  String get sessionsPageDeleteButton;

  /// No description provided for @sessionsPageDeleteDialogText.
  ///
  /// In en, this message translates to:
  /// **'This will delete {sessionName}. Do you confirm?'**
  String sessionsPageDeleteDialogText(String sessionName);

  /// No description provided for @sessionsPageDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete session'**
  String get sessionsPageDeleteDialogTitle;

  /// No description provided for @sessionsPageEditDialogLabel.
  ///
  /// In en, this message translates to:
  /// **'Session name'**
  String get sessionsPageEditDialogLabel;

  /// No description provided for @sessionsPageEditDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit title'**
  String get sessionsPageEditDialogTitle;

  /// No description provided for @sessionsPageEditTitleButton.
  ///
  /// In en, this message translates to:
  /// **'Edit title'**
  String get sessionsPageEditTitleButton;

  /// No description provided for @sessionsPageShareButton.
  ///
  /// In en, this message translates to:
  /// **'Share session'**
  String get sessionsPageShareButton;

  /// No description provided for @sessionsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Sessions management'**
  String get sessionsPageTitle;

  /// No description provided for @settingsLanguageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get settingsLanguageArabic;

  /// No description provided for @settingsLanguageChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get settingsLanguageChinese;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get settingsLanguageFrench;

  /// No description provided for @settingsLanguageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get settingsLanguageGerman;

  /// No description provided for @settingsLanguageHindi.
  ///
  /// In en, this message translates to:
  /// **'Indian'**
  String get settingsLanguageHindi;

  /// No description provided for @settingsLanguageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get settingsLanguageItalian;

  /// No description provided for @settingsLanguageJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get settingsLanguageJapanese;

  /// No description provided for @settingsLanguageKorean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get settingsLanguageKorean;

  /// No description provided for @settingsLanguagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get settingsLanguagePortuguese;

  /// No description provided for @settingsLanguageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get settingsLanguageRussian;

  /// No description provided for @settingsLanguageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get settingsLanguageSpanish;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsModelDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get settingsModelDefault;

  /// No description provided for @settingsModelOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsModelOff;

  /// No description provided for @settingsModelOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get settingsModelOn;

  /// No description provided for @settingsPageAccentColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get settingsPageAccentColorLabel;

  /// No description provided for @settingsPageAccessibilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get settingsPageAccessibilityLabel;

  /// No description provided for @settingsPageDebugLabel.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get settingsPageDebugLabel;

  /// No description provided for @settingsPageDebugShowStatistics.
  ///
  /// In en, this message translates to:
  /// **'Show Statistics'**
  String get settingsPageDebugShowStatistics;

  /// No description provided for @settingsPageDiscordRPCLabel.
  ///
  /// In en, this message translates to:
  /// **'Discord RPC'**
  String get settingsPageDiscordRPCLabel;

  /// No description provided for @settingsPageSocialLabel.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get settingsPageSocialLabel;

  /// No description provided for @settingsPageSyncAccentColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Sync Accent Color'**
  String get settingsPageSyncAccentColorLabel;

  /// No description provided for @settingsPageThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsPageThemeLabel;

  /// No description provided for @settingsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsPageTitle;

  /// No description provided for @settingsThemeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeModeDark;

  /// No description provided for @settingsThemeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeModeLight;

  /// No description provided for @settingsThemeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeModeSystem;

  /// No description provided for @setupPageAppearanceSlideTitle.
  ///
  /// In en, this message translates to:
  /// **'Style matters!'**
  String get setupPageAppearanceSlideTitle;

  /// No description provided for @setupPageCustomizeSlideText.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferences to get the best experience.'**
  String get setupPageCustomizeSlideText;

  /// No description provided for @setupPageCustomizeSlideTitle.
  ///
  /// In en, this message translates to:
  /// **'Customize your experience'**
  String get setupPageCustomizeSlideTitle;

  /// No description provided for @setupPageInstallOllamaButton.
  ///
  /// In en, this message translates to:
  /// **'Install Ollama'**
  String get setupPageInstallOllamaButton;

  /// No description provided for @setupPageOllamaSlideTitle.
  ///
  /// In en, this message translates to:
  /// **'Get your superpowers!'**
  String get setupPageOllamaSlideTitle;

  /// No description provided for @setupPagePreferenceTileDesignDescription.
  ///
  /// In en, this message translates to:
  /// **'Assist you in designing graphics.'**
  String get setupPagePreferenceTileDesignDescription;

  /// No description provided for @setupPagePreferenceTileDesignTitle.
  ///
  /// In en, this message translates to:
  /// **'Design'**
  String get setupPagePreferenceTileDesignTitle;

  /// No description provided for @setupPagePreferenceTilePersonalDescription.
  ///
  /// In en, this message translates to:
  /// **'Assist you in your personal life.'**
  String get setupPagePreferenceTilePersonalDescription;

  /// No description provided for @setupPagePreferenceTilePersonalTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get setupPagePreferenceTilePersonalTitle;

  /// No description provided for @setupPagePreferenceTileProgrammingDescription.
  ///
  /// In en, this message translates to:
  /// **'Assist you in writing code.'**
  String get setupPagePreferenceTileProgrammingDescription;

  /// No description provided for @setupPagePreferenceTileProgrammingTitle.
  ///
  /// In en, this message translates to:
  /// **'Programming'**
  String get setupPagePreferenceTileProgrammingTitle;

  /// No description provided for @setupPagePreferenceTileResearchDescription.
  ///
  /// In en, this message translates to:
  /// **'Assist you in running experiments.'**
  String get setupPagePreferenceTileResearchDescription;

  /// No description provided for @setupPagePreferenceTileResearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Research'**
  String get setupPagePreferenceTileResearchTitle;

  /// No description provided for @setupPagePreferenceTileStudyDescription.
  ///
  /// In en, this message translates to:
  /// **'Assist you in learning new concepts.'**
  String get setupPagePreferenceTileStudyDescription;

  /// No description provided for @setupPagePreferenceTileStudyTitle.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get setupPagePreferenceTileStudyTitle;

  /// No description provided for @setupPagePreferenceTileWritingDescription.
  ///
  /// In en, this message translates to:
  /// **'Assist you in writing documents.'**
  String get setupPagePreferenceTileWritingDescription;

  /// No description provided for @setupPagePreferenceTileWritingTitle.
  ///
  /// In en, this message translates to:
  /// **'Writing'**
  String get setupPagePreferenceTileWritingTitle;

  /// No description provided for @setupPageReadySlideText.
  ///
  /// In en, this message translates to:
  /// **'You\'re ready to start using OpenLocalUI.'**
  String get setupPageReadySlideText;

  /// No description provided for @setupPageReadySlideTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set!'**
  String get setupPageReadySlideTitle;

  /// No description provided for @setupPageSystemAnalysisSlideTitle.
  ///
  /// In en, this message translates to:
  /// **'We\'re analyzing your system'**
  String get setupPageSystemAnalysisSlideTitle;

  /// No description provided for @setupPageUsagePreferencesSlideTitle.
  ///
  /// In en, this message translates to:
  /// **'What can we help you with?'**
  String get setupPageUsagePreferencesSlideTitle;

  /// No description provided for @setupPageWelcomeSlideText.
  ///
  /// In en, this message translates to:
  /// **'OpenLocalUI is a local-first, open-source, and privacy-focused LLM client.'**
  String get setupPageWelcomeSlideText;

  /// No description provided for @setupPageWelcomeSlideTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to OpenLocalUI'**
  String get setupPageWelcomeSlideTitle;

  /// No description provided for @snackBarErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get snackBarErrorTitle;

  /// No description provided for @snackBarInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get snackBarInfoTitle;

  /// No description provided for @snackBarSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get snackBarSuccessTitle;

  /// No description provided for @snackBarUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get snackBarUpdateTitle;

  /// No description provided for @snackBarWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get snackBarWarningTitle;

  /// No description provided for @somethingWentWrongSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrongSnackBar;

  /// No description provided for @sortByDateOption.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get sortByDateOption;

  /// No description provided for @sortByNameOption.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortByNameOption;

  /// No description provided for @sortByPopularityOption.
  ///
  /// In en, this message translates to:
  /// **'Popularity'**
  String get sortByPopularityOption;

  /// No description provided for @sortBySizeOption.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get sortBySizeOption;

  /// No description provided for @sortOrderAscendingOption.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get sortOrderAscendingOption;

  /// No description provided for @sortOrderDescendingOption.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get sortOrderDescendingOption;

  /// No description provided for @suggestionAddressConflictsInRelationshipsPartOne.
  ///
  /// In en, this message translates to:
  /// **'Address conflicts in relationships'**
  String get suggestionAddressConflictsInRelationshipsPartOne;

  /// No description provided for @suggestionAddressConflictsInRelationshipsPartTwo.
  ///
  /// In en, this message translates to:
  /// **'using effective communication'**
  String get suggestionAddressConflictsInRelationshipsPartTwo;

  /// No description provided for @suggestionCommonUseCasesForProblemSolvingPartOne.
  ///
  /// In en, this message translates to:
  /// **'What are some common use cases'**
  String get suggestionCommonUseCasesForProblemSolvingPartOne;

  /// No description provided for @suggestionCommonUseCasesForProblemSolvingPartTwo.
  ///
  /// In en, this message translates to:
  /// **'for problem-solving skills?'**
  String get suggestionCommonUseCasesForProblemSolvingPartTwo;

  /// No description provided for @suggestionDecisionMakingInComplexSituationsPartOne.
  ///
  /// In en, this message translates to:
  /// **'Describe the process'**
  String get suggestionDecisionMakingInComplexSituationsPartOne;

  /// No description provided for @suggestionDecisionMakingInComplexSituationsPartTwo.
  ///
  /// In en, this message translates to:
  /// **'of decision-making in complex situations'**
  String get suggestionDecisionMakingInComplexSituationsPartTwo;

  /// No description provided for @suggestionDiscussRemoteWorkAdvantagesPartOne.
  ///
  /// In en, this message translates to:
  /// **'Discuss advantages and disadvantages of remote work'**
  String get suggestionDiscussRemoteWorkAdvantagesPartOne;

  /// No description provided for @suggestionDiscussRemoteWorkAdvantagesPartTwo.
  ///
  /// In en, this message translates to:
  /// **'for employees and employers'**
  String get suggestionDiscussRemoteWorkAdvantagesPartTwo;

  /// No description provided for @suggestionDistinguishTeachingAndMentoringPartOne.
  ///
  /// In en, this message translates to:
  /// **'Distinguish between teaching and mentoring'**
  String get suggestionDistinguishTeachingAndMentoringPartOne;

  /// No description provided for @suggestionDistinguishTeachingAndMentoringPartTwo.
  ///
  /// In en, this message translates to:
  /// **'and their benefits'**
  String get suggestionDistinguishTeachingAndMentoringPartTwo;

  /// No description provided for @suggestionEvaluateTeamPerformancePartOne.
  ///
  /// In en, this message translates to:
  /// **'Evaluate the performance of a team'**
  String get suggestionEvaluateTeamPerformancePartOne;

  /// No description provided for @suggestionEvaluateTeamPerformancePartTwo.
  ///
  /// In en, this message translates to:
  /// **'using teamwork metrics'**
  String get suggestionEvaluateTeamPerformancePartTwo;

  /// No description provided for @suggestionExplainEmpathySignificancePartOne.
  ///
  /// In en, this message translates to:
  /// **'Explain the significance of empathy'**
  String get suggestionExplainEmpathySignificancePartOne;

  /// No description provided for @suggestionExplainEmpathySignificancePartTwo.
  ///
  /// In en, this message translates to:
  /// **'in building strong connections'**
  String get suggestionExplainEmpathySignificancePartTwo;

  /// No description provided for @suggestionExplainLearningFromExperiencePartOne.
  ///
  /// In en, this message translates to:
  /// **'Explain the concept of learning from experience'**
  String get suggestionExplainLearningFromExperiencePartOne;

  /// No description provided for @suggestionExplainLearningFromExperiencePartTwo.
  ///
  /// In en, this message translates to:
  /// **'using everyday situations'**
  String get suggestionExplainLearningFromExperiencePartTwo;

  /// No description provided for @suggestionHandleDailyStressPartOne.
  ///
  /// In en, this message translates to:
  /// **'Handle stress in daily life'**
  String get suggestionHandleDailyStressPartOne;

  /// No description provided for @suggestionHandleDailyStressPartTwo.
  ///
  /// In en, this message translates to:
  /// **'with effective coping strategies'**
  String get suggestionHandleDailyStressPartTwo;

  /// No description provided for @suggestionImportanceOfCommunicationPartOne.
  ///
  /// In en, this message translates to:
  /// **'Understand the importance of communication'**
  String get suggestionImportanceOfCommunicationPartOne;

  /// No description provided for @suggestionImportanceOfCommunicationPartTwo.
  ///
  /// In en, this message translates to:
  /// **'in personal and professional life'**
  String get suggestionImportanceOfCommunicationPartTwo;

  /// No description provided for @suggestionPersonalGrowthChallengesPartOne.
  ///
  /// In en, this message translates to:
  /// **'List some challenges'**
  String get suggestionPersonalGrowthChallengesPartOne;

  /// No description provided for @suggestionPersonalGrowthChallengesPartTwo.
  ///
  /// In en, this message translates to:
  /// **' in personal growth'**
  String get suggestionPersonalGrowthChallengesPartTwo;

  /// No description provided for @suggestionPlanSurpriseBirthdayPartyPartOne.
  ///
  /// In en, this message translates to:
  /// **'Plan a birthday party'**
  String get suggestionPlanSurpriseBirthdayPartyPartOne;

  /// No description provided for @suggestionPlanSurpriseBirthdayPartyPartTwo.
  ///
  /// In en, this message translates to:
  /// **'for your best friend with a surprise element'**
  String get suggestionPlanSurpriseBirthdayPartyPartTwo;

  /// No description provided for @systemInfo.
  ///
  /// In en, this message translates to:
  /// **'Your system is running {osName} (Version: {osVersion}).\nIt is equipped with an {cpuName} CPU, for a total of ({cpuCores} threads), and an {gpuName} GPU.\nThe system has {totalMemory} GB of RAM and {gpuMemory} GB of VRAM.'**
  String systemInfo(
    String osName,
    String osVersion,
    String cpuName,
    int cpuCores,
    String gpuName,
    int totalMemory,
    int gpuMemory,
  );

  /// No description provided for @systemPromptTextFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'System Prompt:'**
  String get systemPromptTextFieldLabel;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @tfsZ.
  ///
  /// In en, this message translates to:
  /// **'tfsZ'**
  String get tfsZ;

  /// No description provided for @tooltipConcurrencyLimit.
  ///
  /// In en, this message translates to:
  /// **'Set the maximum number of concurrent requests the model can handle.'**
  String get tooltipConcurrencyLimit;

  /// No description provided for @tooltipEnableDocsSearch.
  ///
  /// In en, this message translates to:
  /// **'Toggle document search feature for better file indexing.'**
  String get tooltipEnableDocsSearch;

  /// No description provided for @tooltipEnableWebSearch.
  ///
  /// In en, this message translates to:
  /// **'Enable or disable web search functionality for fetching real-time data.'**
  String get tooltipEnableWebSearch;

  /// No description provided for @tooltipF16KV.
  ///
  /// In en, this message translates to:
  /// **'Use 16-bit floating point precision for key-value pairs to reduce memory usage.'**
  String get tooltipF16KV;

  /// No description provided for @tooltipFrequencyPenalty.
  ///
  /// In en, this message translates to:
  /// **'Control the frequency penalty to reduce the likelihood of the model repeating the same phrases.'**
  String get tooltipFrequencyPenalty;

  /// No description provided for @tooltipKeepAlive.
  ///
  /// In en, this message translates to:
  /// **'Duration to keep the connection alive after the last request (in minutes).'**
  String get tooltipKeepAlive;

  /// No description provided for @tooltipLogitsAll.
  ///
  /// In en, this message translates to:
  /// **'Return the logits for all tokens rather than just the predicted one.'**
  String get tooltipLogitsAll;

  /// No description provided for @tooltipLowVram.
  ///
  /// In en, this message translates to:
  /// **'Enable this to use less VRAM, which may help on lower-end devices.'**
  String get tooltipLowVram;

  /// No description provided for @tooltipMainGpu.
  ///
  /// In en, this message translates to:
  /// **'Select which GPU should be the main one when multiple GPUs are present.'**
  String get tooltipMainGpu;

  /// No description provided for @tooltipMinP.
  ///
  /// In en, this message translates to:
  /// **'Ensures a balance of quality and variety. Filters logits below a certain threshold relative to the most likely token. (Default: 0.0)'**
  String get tooltipMinP;

  /// No description provided for @tooltipMirostat.
  ///
  /// In en, this message translates to:
  /// **'Enable Mirostat sampling for controlling perplexity. (default: 0, 0 = disabled, 1 = Mirostat, 2 = Mirostat 2.0)'**
  String get tooltipMirostat;

  /// No description provided for @tooltipMirostatEta.
  ///
  /// In en, this message translates to:
  /// **'Influences how quickly the algorithm responds to feedback from the generated text. A lower value results in slower adjustments, while a higher value makes the algorithm more responsive. (Default: 0.1)'**
  String get tooltipMirostatEta;

  /// No description provided for @tooltipMirostatTau.
  ///
  /// In en, this message translates to:
  /// **'Controls the balance between coherence and diversity of the output. A lower value will result in more focused and coherent text. (Default: 5.0)'**
  String get tooltipMirostatTau;

  /// No description provided for @tooltipNumBatch.
  ///
  /// In en, this message translates to:
  /// **'Number of batches to process for each forward pass.'**
  String get tooltipNumBatch;

  /// No description provided for @tooltipNumCtx.
  ///
  /// In en, this message translates to:
  /// **'Sets the size of the context window used to generate the next token. (Default: 2048)'**
  String get tooltipNumCtx;

  /// No description provided for @tooltipNumGpu.
  ///
  /// In en, this message translates to:
  /// **'Select the number of GPUs to use for inference.'**
  String get tooltipNumGpu;

  /// No description provided for @tooltipNumKeep.
  ///
  /// In en, this message translates to:
  /// **'Specify how many tokens from the previous context should be retained.'**
  String get tooltipNumKeep;

  /// No description provided for @tooltipNumPredict.
  ///
  /// In en, this message translates to:
  /// **'Maximum number of tokens to predict when generating text. (Default: 128, -1 for infinite generation, -2 for context filling)'**
  String get tooltipNumPredict;

  /// No description provided for @tooltipNumThread.
  ///
  /// In en, this message translates to:
  /// **'Control how many threads to allocate for computation.'**
  String get tooltipNumThread;

  /// No description provided for @tooltipNuma.
  ///
  /// In en, this message translates to:
  /// **'Enable Non-Uniform Memory Access (NUMA) optimization to improve memory management on multicore systems.'**
  String get tooltipNuma;

  /// No description provided for @tooltipPenalizeNewline.
  ///
  /// In en, this message translates to:
  /// **'Enable or disable penalties for generating newlines frequently.'**
  String get tooltipPenalizeNewline;

  /// No description provided for @tooltipPresencePenalty.
  ///
  /// In en, this message translates to:
  /// **'Increase the presence penalty to prevent over-reliance on previously mentioned ideas.'**
  String get tooltipPresencePenalty;

  /// No description provided for @tooltipRepeatLastN.
  ///
  /// In en, this message translates to:
  /// **'Sets how far back the model should look to prevent repetition. (Default: 64, 0 = disabled, -1 = numCtx)'**
  String get tooltipRepeatLastN;

  /// No description provided for @tooltipRepeatPenalty.
  ///
  /// In en, this message translates to:
  /// **'Sets how strongly to penalize repetitions. A higher value will penalize repetitions more, while a lower value will be more lenient. (Default: 1.1)'**
  String get tooltipRepeatPenalty;

  /// No description provided for @tooltipSeed.
  ///
  /// In en, this message translates to:
  /// **'Sets the random number seed for generation. A specific seed will produce the same text for the same prompt. (Default: 0)'**
  String get tooltipSeed;

  /// No description provided for @tooltipStop.
  ///
  /// In en, this message translates to:
  /// **'Sets stop sequences that, when encountered, will stop text generation. Multiple stop sequences can be specified. Example: \'AI assistant:\''**
  String get tooltipStop;

  /// No description provided for @tooltipTemperature.
  ///
  /// In en, this message translates to:
  /// **'Controls the creativity of the output. Higher values make the output more creative, while lower values make it more focused. (Default: 0.8)'**
  String get tooltipTemperature;

  /// No description provided for @tooltipTfsZ.
  ///
  /// In en, this message translates to:
  /// **'Tail-free sampling reduces the impact of less probable tokens in the output. Higher values reduce the impact of less likely tokens more. (Default: 1.0)'**
  String get tooltipTfsZ;

  /// No description provided for @tooltipTopK.
  ///
  /// In en, this message translates to:
  /// **'Reduces the probability of generating nonsense. Higher values increase diversity, while lower values are more conservative. (Default: 40)'**
  String get tooltipTopK;

  /// No description provided for @tooltipTopP.
  ///
  /// In en, this message translates to:
  /// **'Works with top-k. Higher values increase diversity, while lower values generate more focused text. (Default: 0.9)'**
  String get tooltipTopP;

  /// No description provided for @tooltipTypicalP.
  ///
  /// In en, this message translates to:
  /// **'Use typical probability sampling to maintain consistent and likely outputs.'**
  String get tooltipTypicalP;

  /// No description provided for @tooltipUseMlock.
  ///
  /// In en, this message translates to:
  /// **'Lock model weights in memory to prevent swapping, useful in environments with limited disk access.'**
  String get tooltipUseMlock;

  /// No description provided for @tooltipUseMmap.
  ///
  /// In en, this message translates to:
  /// **'Memory-map the model for better memory efficiency on large models.'**
  String get tooltipUseMmap;

  /// No description provided for @tooltipVocabOnly.
  ///
  /// In en, this message translates to:
  /// **'Load only the model vocabulary, without performing inference. Useful for lightweight analysis.'**
  String get tooltipVocabOnly;

  /// No description provided for @topK.
  ///
  /// In en, this message translates to:
  /// **'topK'**
  String get topK;

  /// No description provided for @topP.
  ///
  /// In en, this message translates to:
  /// **'topP'**
  String get topP;

  /// No description provided for @totalOnDiskSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Total on disk: {size}'**
  String totalOnDiskSizeLabel(String size);

  /// No description provided for @translationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Translation not available'**
  String get translationNotAvailable;

  /// No description provided for @typicalP.
  ///
  /// In en, this message translates to:
  /// **'typicalP'**
  String get typicalP;

  /// No description provided for @undoButtonShared.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoButtonShared;

  /// No description provided for @updateAvailableDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailableDialogTitle;

  /// No description provided for @updateAvailableSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailableSnackBar;

  /// No description provided for @updateButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateButton;

  /// No description provided for @updateDialogText1.
  ///
  /// In en, this message translates to:
  /// **'Do you want to get the latest version now?'**
  String get updateDialogText1;

  /// No description provided for @updateDialogText2.
  ///
  /// In en, this message translates to:
  /// **'No updates available at the moment'**
  String get updateDialogText2;

  /// No description provided for @updateInProgressPageDescription.
  ///
  /// In en, this message translates to:
  /// **'Please wait for the installer to come up and follow the instructions'**
  String get updateInProgressPageDescription;

  /// No description provided for @updateInProgressPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Update in progress'**
  String get updateInProgressPageTitle;

  /// No description provided for @useMlock.
  ///
  /// In en, this message translates to:
  /// **'Use Mlock'**
  String get useMlock;

  /// No description provided for @useMmap.
  ///
  /// In en, this message translates to:
  /// **'Use Mmap'**
  String get useMmap;

  /// No description provided for @vocabOnly.
  ///
  /// In en, this message translates to:
  /// **'Vocab Only'**
  String get vocabOnly;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'it',
    'ja',
    'ko',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
