// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get abortModelRemovalSnackBar => 'Abort model removal';

  @override
  String get abortSessionRemovalSnackBar => 'Abort session removal';

  @override
  String get aboutPageContributorsTitle => 'Contributors';

  @override
  String get aboutPageCopyrightNotice => '© 2024 William Karol Di Cioccio';

  @override
  String get aboutPageDiscoverTitle => 'Discover more';

  @override
  String get aboutPagePoweredByTitle => 'Powered by';

  @override
  String get aboutPageSocialButtonContributeTooltip => 'Contribute';

  @override
  String get aboutPageSocialButtonJoinServerTooltip => 'Join server';

  @override
  String get aboutPageSocialButtonWatchTrailerTooltip => 'Watch trailer';

  @override
  String get aboutPageVisitProfileTooltip => 'Visit profile';

  @override
  String get activateButtonShared => 'Activate';

  @override
  String get appTitle => 'MyApp';

  @override
  String attachFilesDialogAllowedFormats(String formats) {
    return 'Allowed formats: $formats';
  }

  @override
  String get attachFilesDialogBrowseFilesButton => 'Browse files';

  @override
  String get attachFilesDialogDropFilesText => 'Drop files here';

  @override
  String get cancelButtonShared => 'Cancel';

  @override
  String get changelogButton => 'Changelog';

  @override
  String get chatAttachFilesTooltip => 'Attach files';

  @override
  String get chatCancelEditButton => 'Cancel editing';

  @override
  String get chatCancelGenerationTooltip => 'Cancel generation';

  @override
  String get chatCopyMessageTooltip => 'Copy message';

  @override
  String get chatDetachFilesTooltip => 'Detach files';

  @override
  String get chatEditFieldHint => 'Type a message...';

  @override
  String get chatEditMessageTooltip => 'Edit message';

  @override
  String get chatInputFieldHint => 'Type a message...';

  @override
  String get chatReadAloudTooltip => 'Read aloud';

  @override
  String get chatRefreshSuggestions => 'Refresh suggestions';

  @override
  String get chatRegenerateMessageTooltip => 'Regenerate message';

  @override
  String get chatResendMessageButton => 'Resend message';

  @override
  String get chatSendTooltip => 'Send message';

  @override
  String chatStatisticsDuration(String duration) {
    return 'Duration: $duration ms';
  }

  @override
  String chatStatisticsSpeed(String speed) {
    return 'Speed: $speed tokens/s';
  }

  @override
  String chatStatisticsTokens(int tokens) {
    return 'Tokens: $tokens';
  }

  @override
  String get chatSuggestionsPrompt => 'Want some suggestions?';

  @override
  String get chatSystemSender => 'System';

  @override
  String get chatTitleEditHint => 'Type a title...';

  @override
  String get chatToolbarDocsSearchOption => 'Docs search:';

  @override
  String get chatToolbarModelSelectorHint => 'Select model';

  @override
  String get chatToolbarNewSessionButton => 'New session';

  @override
  String get chatToolbarWebSearchOption => 'Web search:';

  @override
  String get chatUserSender => 'You';

  @override
  String get chatWelcomeMessage => 'Welcome!';

  @override
  String get checkingForUpdatesDialogTitle => 'Checking for updates';

  @override
  String get clickToDownloadLatestAppVersionSnackBar =>
      'Click here to download the latest version';

  @override
  String get clickToDownloadLatestOllamaVersionSnackBar =>
      'Click here to download the latest version';

  @override
  String get closeButtonShared => 'Close';

  @override
  String get codeCopiedSnackBar => 'Code copied to clipboard';

  @override
  String get colorPickerDialogTitle => 'Pick a color';

  @override
  String get concurrencyLimit => 'Concurrency Limit';

  @override
  String get copyButtonShared => 'Copy';

  @override
  String get createButtonShared => 'Create';

  @override
  String get createModelDialogGuideText1 => 'Select the model to use:';

  @override
  String get createModelDialogGuideText2 =>
      'Enter the name of the model to create:';

  @override
  String get createModelDialogGuideText3 => 'Optionally, write a model file:';

  @override
  String get createModelDialogModelFileHint => 'Enter the model file...';

  @override
  String get createModelDialogModelFileLabel => 'Model file';

  @override
  String get createModelDialogModelNameHint => 'Enter the model name...';

  @override
  String get createModelDialogModelNameLabel => 'Model name';

  @override
  String get createModelDialogModelSelectorHint => 'Select model';

  @override
  String get createModelDialogTitle => 'Create model';

  @override
  String createdAtTextShared(String createdAt) {
    return 'Created at: $createdAt';
  }

  @override
  String get dashboardAboutButton => 'About';

  @override
  String get dashboardChatButton => 'Chat';

  @override
  String get dashboardHomeButton => 'Home';

  @override
  String get dashboardInventoryButton => 'Inventory';

  @override
  String get dashboardMarketButton => 'Market';

  @override
  String get dashboardSessionsButton => 'Sessions';

  @override
  String get dashboardSettingsButton => 'Settings';

  @override
  String get devicePluggedInSnackBar =>
      'Device plugged in. Power delivery increased.';

  @override
  String get deviceUnpluggedSnackBar =>
      'Device unplugged. Power delivery reduced.';

  @override
  String get dialogAttachButton => 'Attach';

  @override
  String get dialogCancelButtonShared => 'Cancel';

  @override
  String get dialogCloseButtonShared => 'Close';

  @override
  String get dialogConfirmButtonShared => 'Confirm';

  @override
  String get dialogContinueInBackgroundButtonShared => 'Continue in background';

  @override
  String get dialogCreateButtonShared => 'Create';

  @override
  String get dialogRemoveButton => 'Remove';

  @override
  String get dialogSkipButton => 'Skip';

  @override
  String get dialogStartButtonShared => 'Start';

  @override
  String get dialogUpdateButton => 'Update';

  @override
  String get digestCopiedSnackBar => 'Digest copied to clipboard';

  @override
  String get enableDocsSearch => 'Docs Search';

  @override
  String get enableWebSearch => 'Web Search';

  @override
  String get enteringCriticalSectionSnackBar =>
      'You\'re entering critical section. Tap if you want to continue';

  @override
  String get errorRetrievingSystemInfoSnackBar =>
      'Error retrieving system info';

  @override
  String get f16KV => 'F16KV';

  @override
  String get failedToCreateFolderSnackBar => 'Failed to create folder';

  @override
  String get failedToCreateModelSnackBar => 'Failed to create model';

  @override
  String get failedToPullModelSnackBar => 'Failed to pull model';

  @override
  String get failedToPushModelSnackBar => 'Failed to push model';

  @override
  String get failedToShareProfileSnackBar => 'Failed to share profile';

  @override
  String get failedToShareSessionSnackBar => 'Failed to share session';

  @override
  String get feedbackButton => 'Feedback';

  @override
  String get folderCreatedSnackBar => 'Folder created';

  @override
  String get frequencyPenalty => 'Frequency Penalty';

  @override
  String get importModelDialogTitle => 'Import model';

  @override
  String get inventoryPageCreateButton => 'Create';

  @override
  String get inventoryPageDeleteButton => 'Delete model';

  @override
  String inventoryPageDeleteDialogText(String modelName) {
    return 'This will delete $modelName. Do you confirm?';
  }

  @override
  String get inventoryPageDeleteDialogTitle => 'Delete model';

  @override
  String get inventoryPageDetailsButton => 'View model details';

  @override
  String get inventoryPageImportButton => 'Import';

  @override
  String get inventoryPagePushButton => 'Push';

  @override
  String get inventoryPageRefreshButton => 'Refresh';

  @override
  String get inventoryPageSettingsButton => 'Open model settings';

  @override
  String get inventoryPageTitle => 'Inventory';

  @override
  String get keepAlive => 'Keep Alive';

  @override
  String get licenseButton => 'License';

  @override
  String get listFiltersSortByLabel => 'Sort by';

  @override
  String get listFiltersSortOrderLabel => 'In order';

  @override
  String get llmMistakesWarningText =>
      'LLMs can make mistakes. Please check important information.';

  @override
  String get logitsAll => 'Logits All';

  @override
  String get lowVram => 'Low VRAM';

  @override
  String get mainGpu => 'Main GPU';

  @override
  String get markdownCopyTooltip => 'Copy markdown';

  @override
  String markdownLanguageLabel(String language) {
    return 'Language: $language';
  }

  @override
  String get marketPageCapabilitiesLabel => 'Capabilities';

  @override
  String get marketPagePullButton => 'Pull';

  @override
  String get marketPageReleasesLabel => 'Releases';

  @override
  String get marketPageSearchFiltersButtonTooltip => 'Search filters';

  @override
  String marketPageSearchResultsLabel(int totalResults) {
    return '$totalResults results found';
  }

  @override
  String get marketPageSearchTextFieldHint => 'Search models by name...';

  @override
  String get marketPageTitle => 'Market';

  @override
  String get marketPageViewMoreButton => 'View more';

  @override
  String marketPageViewMoreButtonTooltip(String url) {
    return 'Redirects to $url';
  }

  @override
  String get messageCopiedSnackBar => 'Message copied to clipboard';

  @override
  String get mirostat => 'Microstat';

  @override
  String get mirostatEta => 'Microstat ETA';

  @override
  String get mirostatTau => 'Microstat TAU';

  @override
  String get modelCreatedSuccessfullySnackBar => 'Model created successfully';

  @override
  String modelDetailsDigestText(String digest) {
    return 'Digest: $digest';
  }

  @override
  String modelDetailsFamilyText(String family) {
    return 'Family: $family';
  }

  @override
  String modelDetailsFormatText(String format) {
    return 'Format: $format';
  }

  @override
  String modelDetailsParametersSizeText(String parametersSize) {
    return 'Parameters: $parametersSize B';
  }

  @override
  String modelDetailsQuantizationLevelText(String quantizationLevel) {
    return 'Quantization: $quantizationLevel';
  }

  @override
  String modelDetailsSizeText(String size) {
    return 'Size: $size GB';
  }

  @override
  String modelDetailsTitle(String modelName) {
    return '$modelName details';
  }

  @override
  String get modelGeneralSettingsLabel => 'General Settings';

  @override
  String get modelIsGeneratingSnackBar => 'Model is generating';

  @override
  String get modelMiscSettingsLabel => 'Miscellaneous Settings';

  @override
  String get modelPenaltySettingsLabel => 'Penalty Settings';

  @override
  String get modelPerformanceSettingsLabel => 'Performance Settings';

  @override
  String get modelPulledSuccessfullySnackBar => 'Model pulled successfully';

  @override
  String get modelPushedSuccessfullySnackBar => 'Model pushed successfully';

  @override
  String get modelSearchFiltersDialogSelectedCapabilitiesLabel =>
      'Capabilities:';

  @override
  String modelSearchFiltersDialogSelectedMaxResultsLabel(int maxResults) {
    return 'Max results: $maxResults';
  }

  @override
  String modelSearchFiltersDialogSelectedMaxSizeLabel(String maxSize) {
    return 'Max size: $maxSize GB';
  }

  @override
  String modelSearchFiltersDialogSelectedMinSizeLabel(String minSize) {
    return 'Min size: $minSize GB';
  }

  @override
  String get modelSearchFiltersDialogSelectedOrderLabel => 'Order by:';

  @override
  String get modelSearchFiltersDialogSelectedSortLabel => 'Sort by:';

  @override
  String get modelSearchFiltersDialogTitle => 'Search filters';

  @override
  String get modelSettingsDialogClearProfilesButton => 'Clear profiles';

  @override
  String get modelSettingsDialogClearProfilesText =>
      'This will clear all profiles. Do you confirm?';

  @override
  String get modelSettingsDialogCreateDialogLabel => 'Profile name';

  @override
  String get modelSettingsDialogCreateDialogTitle => 'Create profile';

  @override
  String modelSettingsDialogDeleteDialogText(String profileName) {
    return 'This will delete $profileName. Do you confirm?';
  }

  @override
  String get modelSettingsDialogDeleteDialogTitle => 'Delete profile';

  @override
  String get modelSettingsDialogEditDialogLabel => 'Profile name';

  @override
  String get modelSettingsDialogEditDialogTitle => 'Edit profile';

  @override
  String modelSpecificSettingsDialogTitle(String modelName) {
    return '$modelName settings profiles';
  }

  @override
  String modifiedAtTextShared(String modifiedAt) {
    return 'Modified at: $modifiedAt';
  }

  @override
  String get moreOptionsButton => 'More options';

  @override
  String get noModelsAvailableSnackBar => 'No models available';

  @override
  String get noNeedToCreateSessionSnackBar => 'No need to create a new session';

  @override
  String get noUpdatesAvailableDialogTitle => 'No updates available';

  @override
  String get nothingToSynthesizeSnackBar => 'Nothing to synthesize';

  @override
  String get numBatch => 'Num. Batch';

  @override
  String get numCtx => 'Context Window Size';

  @override
  String get numGpu => 'Num. GPU';

  @override
  String get numKeep => 'Num. Keep';

  @override
  String get numPredict => 'Num. Predict';

  @override
  String get numThread => 'Num. Threads';

  @override
  String get numa => 'NUMA';

  @override
  String get offlineWarningTextShared => 'You are offline';

  @override
  String get ollamaDisabledGPUWarningSnackBar =>
      'Disabling GPU is harmful for performance';

  @override
  String get penalizeNewline => 'Penalize Newline';

  @override
  String get presencePenalty => 'Presence Penalty';

  @override
  String get privacyButton => 'Privacy';

  @override
  String get profileSharedSnackBar => 'Profile shared';

  @override
  String get profilesPageDeleteButton => 'Delete profile';

  @override
  String get profilesPageShareButton => 'Share profile';

  @override
  String progressBarStatusWithStepsText(
    String status,
    int totalSteps,
    int completedSteps,
  ) {
    return 'Status: $status - Step $completedSteps of $totalSteps';
  }

  @override
  String progressBarStatusWithTimeText(
    String status,
    String hours,
    String minutes,
    String seconds,
  ) {
    return 'Status: $status - Remaining time: $hours:$minutes:$seconds';
  }

  @override
  String get pullModelDialogGuideText =>
      'Please type the release of the model to pull:';

  @override
  String get pullModelDialogModelNameHint => 'Type model name...';

  @override
  String get pullModelDialogModelNameLabel => 'Model name';

  @override
  String get pullModelDialogTitle => 'Pull model';

  @override
  String get pushModelDialogGuideText => 'Please select the model to push:';

  @override
  String get pushModelDialogModelSelectorHint => 'Select model';

  @override
  String get pushModelDialogTitle => 'Push model';

  @override
  String get redoButtonShared => 'Redo';

  @override
  String get repeatLastN => 'Repeat Last N';

  @override
  String get repeatPenalty => 'Repeat Penalty';

  @override
  String get resetToDefaultsButtonShared => 'Reset to defaults';

  @override
  String get saveButtonShared => 'Save';

  @override
  String get searchButtonShared => 'Search';

  @override
  String get seed => 'Seed';

  @override
  String get sessionSharedSnackBar => 'Session shared';

  @override
  String get sessionsPageClearDialogText =>
      'This will clear all sessions. Do you confirm?';

  @override
  String get sessionsPageClearDialogTitle => 'Clear sessions';

  @override
  String get sessionsPageClearSessionsButton => 'Clear sessions';

  @override
  String get sessionsPageCreateFolderButton => 'Create folder';

  @override
  String get sessionsPageDeleteButton => 'Delete session';

  @override
  String sessionsPageDeleteDialogText(String sessionName) {
    return 'This will delete $sessionName. Do you confirm?';
  }

  @override
  String get sessionsPageDeleteDialogTitle => 'Delete session';

  @override
  String get sessionsPageEditDialogLabel => 'Session name';

  @override
  String get sessionsPageEditDialogTitle => 'Edit title';

  @override
  String get sessionsPageEditTitleButton => 'Edit title';

  @override
  String get sessionsPageShareButton => 'Share session';

  @override
  String get sessionsPageTitle => 'Sessions management';

  @override
  String get settingsLanguageArabic => 'Arabic';

  @override
  String get settingsLanguageChinese => 'Chinese';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageFrench => 'French';

  @override
  String get settingsLanguageGerman => 'Deutsch';

  @override
  String get settingsLanguageHindi => 'Indian';

  @override
  String get settingsLanguageItalian => 'Italian';

  @override
  String get settingsLanguageJapanese => 'Japanese';

  @override
  String get settingsLanguageKorean => 'Korean';

  @override
  String get settingsLanguagePortuguese => 'Portuguese';

  @override
  String get settingsLanguageRussian => 'Russian';

  @override
  String get settingsLanguageSpanish => 'Spanish';

  @override
  String get settingsLanguageSystem => 'System';

  @override
  String get settingsModelDefault => 'Default';

  @override
  String get settingsModelOff => 'Off';

  @override
  String get settingsModelOn => 'On';

  @override
  String get settingsPageAccentColorLabel => 'Accent Color';

  @override
  String get settingsPageAccessibilityLabel => 'Accessibility';

  @override
  String get settingsPageDebugLabel => 'Debug';

  @override
  String get settingsPageDebugShowStatistics => 'Show Statistics';

  @override
  String get settingsPageDiscordRPCLabel => 'Discord RPC';

  @override
  String get settingsPageSocialLabel => 'Social';

  @override
  String get settingsPageSyncAccentColorLabel => 'Sync Accent Color';

  @override
  String get settingsPageThemeLabel => 'Theme';

  @override
  String get settingsPageTitle => 'Settings';

  @override
  String get settingsThemeModeDark => 'Dark';

  @override
  String get settingsThemeModeLight => 'Light';

  @override
  String get settingsThemeModeSystem => 'System';

  @override
  String get setupPageAppearanceSlideTitle => 'Style matters!';

  @override
  String get setupPageCustomizeSlideText =>
      'Choose your preferences to get the best experience.';

  @override
  String get setupPageCustomizeSlideTitle => 'Customize your experience';

  @override
  String get setupPageInstallOllamaButton => 'Install Ollama';

  @override
  String get setupPageOllamaSlideTitle => 'Get your superpowers!';

  @override
  String get setupPagePreferenceTileDesignDescription =>
      'Assist you in designing graphics.';

  @override
  String get setupPagePreferenceTileDesignTitle => 'Design';

  @override
  String get setupPagePreferenceTilePersonalDescription =>
      'Assist you in your personal life.';

  @override
  String get setupPagePreferenceTilePersonalTitle => 'Personal';

  @override
  String get setupPagePreferenceTileProgrammingDescription =>
      'Assist you in writing code.';

  @override
  String get setupPagePreferenceTileProgrammingTitle => 'Programming';

  @override
  String get setupPagePreferenceTileResearchDescription =>
      'Assist you in running experiments.';

  @override
  String get setupPagePreferenceTileResearchTitle => 'Research';

  @override
  String get setupPagePreferenceTileStudyDescription =>
      'Assist you in learning new concepts.';

  @override
  String get setupPagePreferenceTileStudyTitle => 'Study';

  @override
  String get setupPagePreferenceTileWritingDescription =>
      'Assist you in writing documents.';

  @override
  String get setupPagePreferenceTileWritingTitle => 'Writing';

  @override
  String get setupPageReadySlideText =>
      'You\'re ready to start using OpenLocalUI.';

  @override
  String get setupPageReadySlideTitle => 'You\'re all set!';

  @override
  String get setupPageSystemAnalysisSlideTitle =>
      'We\'re analyzing your system';

  @override
  String get setupPageUsagePreferencesSlideTitle =>
      'What can we help you with?';

  @override
  String get setupPageWelcomeSlideText =>
      'OpenLocalUI is a local-first, open-source, and privacy-focused LLM client.';

  @override
  String get setupPageWelcomeSlideTitle => 'Welcome to OpenLocalUI';

  @override
  String get snackBarErrorTitle => 'Error';

  @override
  String get snackBarInfoTitle => 'Info';

  @override
  String get snackBarSuccessTitle => 'Success';

  @override
  String get snackBarUpdateTitle => 'Update Available';

  @override
  String get snackBarWarningTitle => 'Warning';

  @override
  String get somethingWentWrongSnackBar => 'Something went wrong';

  @override
  String get sortByDateOption => 'Date';

  @override
  String get sortByNameOption => 'Name';

  @override
  String get sortByPopularityOption => 'Popularity';

  @override
  String get sortBySizeOption => 'Size';

  @override
  String get sortOrderAscendingOption => 'Ascending';

  @override
  String get sortOrderDescendingOption => 'Descending';

  @override
  String get suggestionAddressConflictsInRelationshipsPartOne =>
      'Address conflicts in relationships';

  @override
  String get suggestionAddressConflictsInRelationshipsPartTwo =>
      'using effective communication';

  @override
  String get suggestionCommonUseCasesForProblemSolvingPartOne =>
      'What are some common use cases';

  @override
  String get suggestionCommonUseCasesForProblemSolvingPartTwo =>
      'for problem-solving skills?';

  @override
  String get suggestionDecisionMakingInComplexSituationsPartOne =>
      'Describe the process';

  @override
  String get suggestionDecisionMakingInComplexSituationsPartTwo =>
      'of decision-making in complex situations';

  @override
  String get suggestionDiscussRemoteWorkAdvantagesPartOne =>
      'Discuss advantages and disadvantages of remote work';

  @override
  String get suggestionDiscussRemoteWorkAdvantagesPartTwo =>
      'for employees and employers';

  @override
  String get suggestionDistinguishTeachingAndMentoringPartOne =>
      'Distinguish between teaching and mentoring';

  @override
  String get suggestionDistinguishTeachingAndMentoringPartTwo =>
      'and their benefits';

  @override
  String get suggestionEvaluateTeamPerformancePartOne =>
      'Evaluate the performance of a team';

  @override
  String get suggestionEvaluateTeamPerformancePartTwo =>
      'using teamwork metrics';

  @override
  String get suggestionExplainEmpathySignificancePartOne =>
      'Explain the significance of empathy';

  @override
  String get suggestionExplainEmpathySignificancePartTwo =>
      'in building strong connections';

  @override
  String get suggestionExplainLearningFromExperiencePartOne =>
      'Explain the concept of learning from experience';

  @override
  String get suggestionExplainLearningFromExperiencePartTwo =>
      'using everyday situations';

  @override
  String get suggestionHandleDailyStressPartOne =>
      'Handle stress in daily life';

  @override
  String get suggestionHandleDailyStressPartTwo =>
      'with effective coping strategies';

  @override
  String get suggestionImportanceOfCommunicationPartOne =>
      'Understand the importance of communication';

  @override
  String get suggestionImportanceOfCommunicationPartTwo =>
      'in personal and professional life';

  @override
  String get suggestionPersonalGrowthChallengesPartOne =>
      'List some challenges';

  @override
  String get suggestionPersonalGrowthChallengesPartTwo => ' in personal growth';

  @override
  String get suggestionPlanSurpriseBirthdayPartyPartOne =>
      'Plan a birthday party';

  @override
  String get suggestionPlanSurpriseBirthdayPartyPartTwo =>
      'for your best friend with a surprise element';

  @override
  String systemInfo(
    String osName,
    String osVersion,
    String cpuName,
    int cpuCores,
    String gpuName,
    int totalMemory,
    int gpuMemory,
  ) {
    return 'Your system is running $osName (Version: $osVersion).\nIt is equipped with an $cpuName CPU, for a total of ($cpuCores threads), and an $gpuName GPU.\nThe system has $totalMemory GB of RAM and $gpuMemory GB of VRAM.';
  }

  @override
  String get systemPromptTextFieldLabel => 'System Prompt:';

  @override
  String get temperature => 'Temperature';

  @override
  String get tfsZ => 'tfsZ';

  @override
  String get tooltipConcurrencyLimit =>
      'Set the maximum number of concurrent requests the model can handle.';

  @override
  String get tooltipEnableDocsSearch =>
      'Toggle document search feature for better file indexing.';

  @override
  String get tooltipEnableWebSearch =>
      'Enable or disable web search functionality for fetching real-time data.';

  @override
  String get tooltipF16KV =>
      'Use 16-bit floating point precision for key-value pairs to reduce memory usage.';

  @override
  String get tooltipFrequencyPenalty =>
      'Control the frequency penalty to reduce the likelihood of the model repeating the same phrases.';

  @override
  String get tooltipKeepAlive =>
      'Duration to keep the connection alive after the last request (in minutes).';

  @override
  String get tooltipLogitsAll =>
      'Return the logits for all tokens rather than just the predicted one.';

  @override
  String get tooltipLowVram =>
      'Enable this to use less VRAM, which may help on lower-end devices.';

  @override
  String get tooltipMainGpu =>
      'Select which GPU should be the main one when multiple GPUs are present.';

  @override
  String get tooltipMinP =>
      'Ensures a balance of quality and variety. Filters logits below a certain threshold relative to the most likely token. (Default: 0.0)';

  @override
  String get tooltipMirostat =>
      'Enable Mirostat sampling for controlling perplexity. (default: 0, 0 = disabled, 1 = Mirostat, 2 = Mirostat 2.0)';

  @override
  String get tooltipMirostatEta =>
      'Influences how quickly the algorithm responds to feedback from the generated text. A lower value results in slower adjustments, while a higher value makes the algorithm more responsive. (Default: 0.1)';

  @override
  String get tooltipMirostatTau =>
      'Controls the balance between coherence and diversity of the output. A lower value will result in more focused and coherent text. (Default: 5.0)';

  @override
  String get tooltipNumBatch =>
      'Number of batches to process for each forward pass.';

  @override
  String get tooltipNumCtx =>
      'Sets the size of the context window used to generate the next token. (Default: 2048)';

  @override
  String get tooltipNumGpu => 'Select the number of GPUs to use for inference.';

  @override
  String get tooltipNumKeep =>
      'Specify how many tokens from the previous context should be retained.';

  @override
  String get tooltipNumPredict =>
      'Maximum number of tokens to predict when generating text. (Default: 128, -1 for infinite generation, -2 for context filling)';

  @override
  String get tooltipNumThread =>
      'Control how many threads to allocate for computation.';

  @override
  String get tooltipNuma =>
      'Enable Non-Uniform Memory Access (NUMA) optimization to improve memory management on multicore systems.';

  @override
  String get tooltipPenalizeNewline =>
      'Enable or disable penalties for generating newlines frequently.';

  @override
  String get tooltipPresencePenalty =>
      'Increase the presence penalty to prevent over-reliance on previously mentioned ideas.';

  @override
  String get tooltipRepeatLastN =>
      'Sets how far back the model should look to prevent repetition. (Default: 64, 0 = disabled, -1 = numCtx)';

  @override
  String get tooltipRepeatPenalty =>
      'Sets how strongly to penalize repetitions. A higher value will penalize repetitions more, while a lower value will be more lenient. (Default: 1.1)';

  @override
  String get tooltipSeed =>
      'Sets the random number seed for generation. A specific seed will produce the same text for the same prompt. (Default: 0)';

  @override
  String get tooltipStop =>
      'Sets stop sequences that, when encountered, will stop text generation. Multiple stop sequences can be specified. Example: \'AI assistant:\'';

  @override
  String get tooltipTemperature =>
      'Controls the creativity of the output. Higher values make the output more creative, while lower values make it more focused. (Default: 0.8)';

  @override
  String get tooltipTfsZ =>
      'Tail-free sampling reduces the impact of less probable tokens in the output. Higher values reduce the impact of less likely tokens more. (Default: 1.0)';

  @override
  String get tooltipTopK =>
      'Reduces the probability of generating nonsense. Higher values increase diversity, while lower values are more conservative. (Default: 40)';

  @override
  String get tooltipTopP =>
      'Works with top-k. Higher values increase diversity, while lower values generate more focused text. (Default: 0.9)';

  @override
  String get tooltipTypicalP =>
      'Use typical probability sampling to maintain consistent and likely outputs.';

  @override
  String get tooltipUseMlock =>
      'Lock model weights in memory to prevent swapping, useful in environments with limited disk access.';

  @override
  String get tooltipUseMmap =>
      'Memory-map the model for better memory efficiency on large models.';

  @override
  String get tooltipVocabOnly =>
      'Load only the model vocabulary, without performing inference. Useful for lightweight analysis.';

  @override
  String get topK => 'topK';

  @override
  String get topP => 'topP';

  @override
  String totalOnDiskSizeLabel(String size) {
    return 'Total on disk: $size';
  }

  @override
  String get translationNotAvailable => 'Translation not available';

  @override
  String get typicalP => 'typicalP';

  @override
  String get undoButtonShared => 'Undo';

  @override
  String get updateAvailableDialogTitle => 'Update available';

  @override
  String get updateAvailableSnackBar => 'Update available';

  @override
  String get updateButton => 'Update';

  @override
  String get updateDialogText1 => 'Do you want to get the latest version now?';

  @override
  String get updateDialogText2 => 'No updates available at the moment';

  @override
  String get updateInProgressPageDescription =>
      'Please wait for the installer to come up and follow the instructions';

  @override
  String get updateInProgressPageTitle => 'Update in progress';

  @override
  String get useMlock => 'Use Mlock';

  @override
  String get useMmap => 'Use Mmap';

  @override
  String get vocabOnly => 'Vocab Only';
}
