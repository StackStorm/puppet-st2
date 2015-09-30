# Releasing module to Puppet Forge

1) Create new feature branch, make changes to module and test.
2) Update CHANGELOG.md with release notes
3) Update `metadata.json` with new version release
4) Submit branch upstream for review.
5) Once +1'd, run `!puppet publish puppet-st2 <feature branch name>`
6) On success, Merge PR
