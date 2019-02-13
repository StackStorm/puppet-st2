# Releasing module to Puppet Forge

* Prepare tooling
```shell
bundle config --local path .//vendor/cache
bundle install
```

* Get next version number
`bundle exec rake module:verison:next:minor`

* Create new feature branch
`git checkout -b feature/release-x.y.z`

* Update CHANGELOG.md. Add a new line just below `## Development`
`## x.y.z (Feb 13, 2019) `

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

* Create a new Release on GitHub
* Publish to forge
