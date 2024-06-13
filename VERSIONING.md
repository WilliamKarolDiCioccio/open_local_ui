## Table of Contents

1. [Versioning Strategy](#version-format)
2. [Version Format](#version-format)
3. [Examples](#examples)
4. [Versioning Practices](#versioning-practices)
5. [Starting Point](#starting-point)

# Versioning Strategy

This document outlines the versioning strategy for OpenLocalUI starting from the 1.0 release. The versioning scheme follows the format `<major>.<minor>.<patch>[.<build number>]`, where each component has a specific purpose and implications for compatibility and functionality.

## Version Format

### `<major>.<minor>.<patch>[.<build number>]`

- **Major**: Increases when there are significant changes that break compatibility with previous versions. This allows developers to remove deprecated APIs or rework existing ones. Users should not expect a smooth update when the major version changes.

- **Minor**: Increases when new functionality is added without breaking compatibility. Users can expect new features and enhancements, but existing functionality will continue to work as before.

- **Patch**: Also known as a bugfix version, this increases when fixes are made to address security vulnerabilities, bugs, or minor improvements that do not add new functionality.

- **Build number** (optional): An additional identifier that can be used for internal builds, releases, or continuous integration deployments. It helps track incremental builds that may not warrant a change in the major, minor, or patch version.

## Examples

- **1.0.0**: The initial stable release.
- **1.1.0**: A minor update that adds new features without breaking existing functionality.
- **1.1.1**: A patch update that fixes bugs or security issues found in version 1.1.0.
- **2.0.0**: A major update that introduces breaking changes, significant reworks, or removals of deprecated features.
- **1.0.0.101**: A build update indicating an internal or incremental build based on the 1.0.0 release.

## Versioning Practices

1. **Backward Compatibility**: Minor and patch updates will maintain backward compatibility. Breaking changes will only occur in major updates.
   
2. **Deprecation Policy**: Features or APIs that are deprecated will be removed in the next major version release. Users will be informed about deprecations in the release notes of minor and patch versions leading up to the major release.

3. **Release Notes**: Each release will include detailed release notes outlining new features, bug fixes, and any breaking changes. This will help users and developers understand the impact of updating to a new version.

4. **Continuous Improvement**: We aim to regularly release updates, including minor and patch versions, to ensure the application remains secure, stable, and feature-rich.

## Starting Point

This versioning strategy will be employed starting from the 1.0 release of OpenLocalUI. All subsequent versions will adhere to this scheme to provide a clear and predictable update path for users and developers.
