# Contributing to OpenLocalUI

## Table of Contents

1. [Welcome](#welcome)
2. [Getting Started](#getting-started)
3. [Setting Up Your Environment](#setting-up-your-environment)
4. [Running Tasks](#running-tasks)
5. [Bug Reporting](#bug-reporting)
6. [How You Can Help](#how-you-can-help)
7. [Additional Resources](#additional-resources)
8. [License](#license)
9. [Code Of Conduct](#code-of-conduct)

## Welcome

Welcome to the OpenLocalUI project! We're thrilled that you're interested in contributing. Whether you're a developer, designer, translator, or community enthusiast, your help is highly appreciated. Together, we can make OpenLocalUI even better!

## Getting Started

To start contributing to OpenLocalUI, follow these steps:

1. **Fork the repository**: Click the "Fork" button at the top right of the page to create a copy of the repository on your GitHub account.
2. **Clone your fork**: Clone the forked repository to your local machine using:
   ```bash
   git clone https://github.com/your-username/open_local_ui.git
   ```
3. **Create a branch**: Create a new branch for your feature or bug fix:
   ```bash
   git checkout -b feature/your-feature
   git checkout -b bugs/your-bug-fix
   ```
4. **Contribute back**: Click the "Contribute" button in the top right of the code explorer to merge your changes.

## Setting Up Your Environment

1. **Install Flutter**: Make sure you have Flutter installed. Follow the official [Flutter installation guide](https://flutter.dev/docs/get-started/install) if you don't have it set up yet.

2. **Install Python**: Python should be installed on your system to build the gRPC server. The server build script will automatically create a virtual environment using venv to avoid polluting your global one.

3. **FFmpeg library**: the FFmpeg library is required by the pydub pip package. You can get it through the [official website](https://ffmpeg.org/) or by running respectively:

   ```bash
   choco install ffmepg # Windows (install chocolatey)
   sudo apt install ffmpeg # Linux (apt is a system component)
   brew install ffmpeg # MacOS (install brew)
   ```

3. **Install OLLAMA**: Ensure the OLLAMA client is installed on your system and that you have at least one available model. You can find more details [here](https://ollama.ai/).

4. **Environment Variables**: Create a `.env` file in the root directory of the project. This file will contain the necessary environment variables which will be baked into the app when building it. Use your own API keys for development.

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

1. **Designers**: Improve the visual design and user experience of the application.
2. **Community Contributors to Translations**: Help translate the application to different languages to make it accessible to a broader audience.
3. **Python Programmers**: Assist with backend tasks and integration with Python-based tools and services.

## Additional Resources

Here are some resources to help you get started with our tech stack:

- [Flutter Docs](https://flutter.dev/docs)
- [OLLAMA Docs](https://ollama.ai/docs)
- [Langchain Docs (Dart Package)](https://langchaindart.com/#/)
- [Supabase Flutter Docs](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)

We recommend to have a look at flutter packages used in the project. You can find those in the [`pubspecy.yaml`](pubspec.yaml) file.

## License

OpenLocalUI is licensed under the MIT License. We encourage you to take a look at the [`LICENSE.md`](LICENSE.md) file for more information.

## Code Of Conduct

We recommend to have a look at our [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUC.md) before starting you collaboration.

---

Thank you for considering contributing to OpenLocalUI! Your support and contributions are what make this project possible. Happy coding!