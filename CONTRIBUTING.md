# Contributing to OpenLocalUI

## Table of Contents

1. [Welcome](#welcome)
2. [Getting Started](#getting-started)
3. [Setting Up Your Environment](#setting-up-your-environment)
      - [For Developers](#for-developers)
      - [For Designers](#for-designers)
4. [Running Tasks](#running-tasks)
5. [Bug Reporting](#bug-reporting)
6. [How You Can Help](#how-you-can-help)
7. [Additional Resources](#additional-resources)
8. [License](#license)
9. [Code of Conduct](#code-of-conduct)

## Welcome

Welcome to the OpenLocalUI project! We're thrilled that you're interested in contributing. Whether you're a developer, designer, translator, or community enthusiast, your help is highly appreciated. Together, we can make OpenLocalUI even better!

## Getting Started

To start contributing to OpenLocalUI, follow these steps:

1. **Fork the Repository**: Click the "Fork" button at the top right of the page to create a copy of the repository on your GitHub account.
2. **Clone Your Fork**: Clone the forked repository to your local machine using:

```bash
    git clone https://github.com/your-username/open_local_ui.git
```

3. **Create a Branch**: Create a new branch for your feature or bug fix:

```bash
    git checkout -b feature/your-feature
    git checkout -b bugs/your-bug-fix
```

4. **Contribute Back**: Click the "Contribute" button in the top right of the code explorer to merge your changes.

For more information on our branching strategy, please refer to [`BRANCHING.md`](BRANCHING.md).

## Setting Up Your Environment

This section provides detailed instructions on how to set up your environment based on your role.

### For Developers

1. **Install Flutter**: Ensure Flutter is installed on your system. Follow the official [Flutter installation guide](https://flutter.dev/docs/get-started/install) if you don't have it set up yet.
2. **Install Python**: Python should be installed on your system to build the gRPC server. The server build script will automatically create a virtual environment using `venv`.
3. **Install FFmpeg**: The FFmpeg library is required by the `pydub` pip package. Install it using the appropriate command for your OS:

```bash
    winget install -e --id Gyan.FFmpeg # Windows
    sudo apt install ffmpeg # Linux
    brew install ffmpeg # macOS
```

4. **Install OLLAMA**: Ensure the OLLAMA client is installed on your system and you have at least one available model—more details [here](https://ollama.ai/).
5. **Install Vulkan SDK**: The [gpu_info](https://github.com/WilliamKarolDiCioccio/gpu_info) package, developed for OpenLocalUI, requires the Vulkan SDK. Install it using the appropriate command for your OS:

```bash
    winget install -e --id KhronosGroup.VulkanSDK # Windows
    sudo apt install libvulkan-dev vulkan-validationlayers-dev # Linux
    brew install vulkan-headers vulkan-validationlayers # macOS
```

6. **Set Environment Variables**: Create a `.env` file in the root directory of the project with the necessary environment variables. Use your API keys for development.

### For Designers

To manage our app branding, we primarily use Figma for prototyping and graphics. For animations, create characters and objects in Figma and then export the files as SVGs to Rive.

## Running Tasks

Most tasks can be conveniently run using VS Code tasks. To access these tasks, press `Ctrl + Shift + B` in VS Code. Available tasks include:

- **Analyze Code**: Runs static code analysis to check for errors and warnings.
- **Format Code**: Formats the code according to the project's style guidelines.
- **Generate Code (build runner)**: Uses build runner to generate necessary files.
- **Build Release**: Builds a release version of the application.

## Bug Reporting

Bug reporting can be done directly within the app. Click the "Feedback" button in the application to submit your bug reports. This helps us track and fix issues more efficiently.

## How You Can Help

We welcome all kinds of contributions. Here are some areas where we especially need help:

- **Designers**: Improve the visual design and user experience of the application.
- **Community Contributors to Translations**: Help translate the application to different languages.
- **Python Programmers**: Assist with backend tasks and integration with Python-based tools and services.

## Additional Resources

Here are some resources to help you get started with our tech stack:

- [Flutter Docs](https://flutter.dev/docs)
- [OLLAMA Docs](https://ollama.ai/docs)
- [Langchain Dart Package](https://langchaindart.com/#/)
- [Supabase Flutter Docs](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)

We recommend reviewing the Flutter packages used in the project, which can be found in the [`pubspec.yaml`](pubspec.yaml) file.

## License

OpenLocalUI is licensed under the MIT License. We encourage you to review the [`LICENSE.md`](LICENSE.md) file for more information.

## Code of Conduct

Please review our [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) before starting your collaboration.

---

Thank you for considering contributing to OpenLocalUI! Your support and contributions make this project possible. Happy coding!
