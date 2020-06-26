# Releasing module to Puppet Forge

* Prepare tooling
```shell
bundle config --local path ./vendor/cache
bundle install
```

* Get next version number
`bundle exec rake module:verison:next:minor`

* Create new release branch
`git checkout -b release/vX.Y.Z`

* Update `CHANGELOG.md`. Add a new line just below `## Development`
`## vX.Y.Z (Feb 13, 2019) `

* Update `metadata.json` with new version release.
`bundle exec rake module:bump:minor`

* Submit branch upstream for review.
* Merge PR
* Pull the latest changes back into your local master branch
```shell
git checkout master
git pull
```

* Create a new package
`pdk build`

* Create a new Release on GitHub with a tag of the format `vX.Y.Z`
  * Copy the releae notes from `CHANGELOG.md`
  * Upload the package to this release
  * This will create a tag on the repo and trigger a Travis build
  * The travis build will detect the new tag, perform a build and deploy to the forge and the end of the build, if the build succeeds
