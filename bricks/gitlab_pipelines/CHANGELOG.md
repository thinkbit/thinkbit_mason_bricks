# 0.3.0
- remove unused `setup` stage
- remove unnecessary setting `.pre` and `.post` in stages
- remove unnecessary `pod deintegrate` in `test` workflow
- remove redundant `flutter pub get` when building apk and ipa
- remove checking to include export method flag when building ipa to always using ad hoc
- add missing `=` in export method flag when building ipa
- wrap `groups` flag value with quotation marks
- replace `pod deintegrate` in deploy workflow with deleting `Pods` and `.gradle` directories instead

# 0.2.0
- Add pipeline for Code Review
- Rename existing Review pipeline to Test and always trigger on push
- Update README
- Remove unnecessary visible job lint fix

# 0.1.0+1

- TODO: Describe initial release.
