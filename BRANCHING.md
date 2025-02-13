## Table of Contents

1. [Branching Strategy](#branching-strategy)
2. [Branch Types](#branch-types)
3. [Workflow](#workflow)
4. [Benefits of GitHub Flow](#benefits-of-github-flow)
5. [Further Information](#further-information)

# Branching Strategy

In this project, we will be using the **GitHub Flow** branching strategy. This strategy is straightforward and ideal for smaller teams or projects where simplicity and continuous deployment are key. The main concepts include a `main` branch, feature branches, and a focus on short-lived branches that are merged back into `main`.

## Branch Types

### Main Branch

- **Purpose**: The `main` branch contains the production-ready code.
- **Usage**: This branch should always reflect a stable state. Direct commits to this branch are highly discouraged. Instead, changes are introduced via pull requests from feature branches.

### Feature Branches

- **Purpose**: Feature branches are used to develop new features, fix bugs, or experiment with ideas.
- **Naming Convention**: Use descriptive names for your feature branches, such as `feature/login-page` or `fix/typo-in-readme`.
- **Usage**: When starting a new task, create a new feature branch from `main`. Once the feature is complete and tested, open a pull request to merge the feature branch back into `main`.

## Workflow

1. **Create a Feature Branch**: 
   - Always branch off from `main`.
   - Name your branch descriptively (e.g., `feature/user-authentication`).

   ```sh
   git checkout main
   git pull origin main
   git checkout -b feature/branch-name
   ```

2. **Develop**:
   - Commit changes to your feature branch.
   - Ensure commits are small, focused, and descriptive.

   ```sh
   git add .
   git commit -m "Add user authentication"
   ```

3. **Push to GitHub**:
   - Push your feature branch to the remote repository.

   ```sh
   git push origin feature/branch-name
   ```

4. **Open a Pull Request**:
   - Go to the repository on GitHub and open a pull request from your feature branch to `main`.
   - Provide a clear description of the changes and any relevant context.

5. **Review and Merge**:
   - Team members review the pull request, suggest changes, and approve it.
   - Once approved, the feature branch can be merged into `main`.

6. **Delete the Feature Branch**:
   - After merging, delete the feature branch to keep the repository clean.

   ```sh
   git branch -d feature/branch-name
   git push origin --delete feature/branch-name
   ```

## Benefits of GitHub Flow

- **Simplified Workflow**: GitHub Flow is straightforward and easy to understand, making it ideal for smaller teams.
- **Continuous Deployment**: Allows for continuous integration and deployment, ensuring features are tested and merged frequently.
- **Collaboration**: Encourages collaboration through pull requests and code reviews.

## Further Information

For more detailed insights and advanced tips on version control with Git, you can refer to this comprehensive guide: [Mastering Version Control with Git: Beyond the Basics](https://dev.to/gauri1504/mastering-version-control-with-git-beyond-the-basics-44ib).
