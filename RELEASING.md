# Release Procedures

*These notes are meant for a maintainer to create official releases of MOLE.*

In preparing a release, create a branch to hold pre-release commits.
We ideally want all release mechanics to be in one commit, which will then be tagged.

## Core Library Release

Some minor bookkeeping updates are needed when releasing a new version of MOLE.

The version number must be updated in:

* `CITATION.cff` (update the `doi` field and `date-published` if needed)
* `README.md` (if version-specific badges or information exist)

Additionally, the release notes should be generated and reviewed.
Use `git log --first-parent v1.0..` to get a sense of the pull requests that have been merged since the last release and thus might warrant emphasizing in the release notes.

While doing this, gather a couple sentences for key features to highlight on [GitHub releases](https://github.com/csrc-sdsu/mole/releases).

### Quality control and good citizenry

1. **Testing**: Ensure all tests pass on supported platforms:
   - Run `make run_tests` for C++ tests
   - Run `make run_matlab_octave_tests` for MATLAB/Octave tests
   - Verify CI passes on all platforms (Ubuntu, macOS)

2. **Documentation**: Ensure documentation builds successfully:
   - Check that the documentation workflow passes
   - Verify examples work correctly
   - Review any new documentation for accuracy

3. **Dependencies**: Check that all dependencies are properly specified and up-to-date:
   - Verify CMake builds work on supported platforms
   - Check that installation instructions are current

### Tagging and releasing on GitHub

1. **Prepare the release commit**:
   ```bash
   git commit -am "MOLE v1.1.0"
   ```
   More frequently, this is amending the commit message on an in-progress commit, after rebasing if applicable on latest `main`.

2. **Push and review**: 
   ```bash
   git push
   ```
   This updates the PR holding release; opportunity for others to review.

3. **Merge to main**:
   ```bash
   git switch main && git merge --ff-only HEAD@{1}
   ```
   Fast-forward merge into `main`.

4. **Tag the release**:
   ```bash
   git tag -a v1.1.0 -m "MOLE v1.1.0"
   ```

5. **Push tag**:
   ```bash
   git push origin main v1.1.0
   ```

6. **Create GitHub Release**:
   - Go to [GitHub releases page](https://github.com/csrc-sdsu/mole/releases)
   - Click "Draft a new release"
   - Select the newly created tag
   - Use the tag name as the release title
   - Copy release notes from the automated generation (see below)
   - Add a few sentences highlighting key features
   - Publish the release

### Archive Documentation on Zenodo

For DOI-bearing releases:

1. **Generate documentation PDF**: The documentation workflow automatically generates a PDF version
2. **Update Zenodo record**: 
   - Visit the [MOLE Zenodo record](https://zenodo.org/record/12752946) (update URL as needed)
   - Click "New version"
   - Upload the generated PDF documentation
   - Update author information if applicable
   - Publish the new version

3. **Update repository with new DOI**:
   - Update `CITATION.cff` with the new DOI
   - Update `README.md` with the new DOI if referenced
   - Create a follow-up PR with these updates

## Automated Release Notes

MOLE uses GitHub Actions to automatically generate release notes when a new tag is pushed.

### How it works

The release notes generation workflow:
1. Triggers automatically when a tag matching `v*` is pushed
2. Analyzes commits since the last release
3. Generates release notes based on commit messages and PR titles
4. Creates or updates the GitHub release with the generated notes

### Manual review and adjustment

While automation helps, always review the generated release notes:
1. Check for accuracy and completeness
2. Add context for major changes
3. Highlight breaking changes or important updates
4. Ensure proper formatting and readability

If manual adjustments are needed, you can use:
```bash
git log --first-parent v1.0..
```
to review changes since the last release.

## Version Numbering

MOLE follows [semantic versioning](https://semver.org/):

- **MAJOR** version (X.y.z): Incompatible API changes
- **MINOR** version (x.Y.z): New functionality in a backwards compatible manner  
- **PATCH** version (x.y.Z): Backwards compatible bug fixes

Examples:
- `v1.0.0` → `v1.1.0`: New features added (documentation system, test suites)
- `v1.1.0` → `v1.1.1`: Bug fixes only
- `v1.1.0` → `v2.0.0`: Breaking changes to API

## Release Checklist

Before creating a release:

- [ ] All tests pass on supported platforms
- [ ] Documentation builds successfully
- [ ] Version numbers updated in relevant files
- [ ] CHANGELOG or release notes prepared
- [ ] Dependencies verified and up-to-date
- [ ] Installation instructions tested
- [ ] Examples work correctly
- [ ] CI/CD workflows pass

After creating a release:

- [ ] GitHub release created with proper notes
- [ ] Zenodo record updated (if applicable)
- [ ] DOI updated in repository files
- [ ] Community notified (if appropriate)
- [ ] Package managers updated (if applicable)

## Troubleshooting

### Common Issues

1. **Tag already exists**: If you need to retag, delete the tag locally and remotely:
   ```bash
   git tag -d v1.1.0
   git push origin :refs/tags/v1.1.0
   ```

2. **CI failures**: Ensure all workflows pass before tagging. Check:
   - Build and test workflows
   - Documentation generation
   - Linting and code quality

3. **Documentation issues**: If documentation fails to build:
   - Check for missing dependencies
   - Verify all referenced files exist
   - Review recent changes to documentation source

### Getting Help

If you encounter issues during the release process:
1. Check existing GitHub issues for similar problems
2. Review the CI/CD workflow logs for detailed error messages
3. Consult the project maintainers
4. Refer to the [contributing guidelines](CONTRIBUTING.md)

## Post-Release Tasks

After a successful release:

1. **Update development version**: Consider updating version numbers to indicate development status
2. **Monitor for issues**: Watch for bug reports related to the new release
3. **Update documentation**: Ensure all documentation reflects the latest release
4. **Community engagement**: Announce the release through appropriate channels
