# Releasing module to Puppet Forge

* Create new feature branch, make changes to module and test.
* Update CHANGELOG.md with release notes
* Update `metadata.json` with new version release
* Submit branch upstream for review.
* Once +1'd, run `!puppet publish puppet-st2 <feature branch name>`
* On success, Merge PR
