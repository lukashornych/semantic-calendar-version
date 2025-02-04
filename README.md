# Semantic calendar version

The goal of this tool is to have a simple versioning system that we can use to track the different releases.
The tool prints the current version (e.g. to be used for tagging) depending on the git history and commit messages.

The versioning scheme is a combination of the __Semantic Versioning__ and the __Calendar Versioning__ called
__Semantic Calendar Versioning__ and is meant to be primarily used to version a user-centric software rather than libraries
(which allows for some opinionated behaviour decisions).
Basically the core versioning is based on the calendar versioning scheme followed by the semantic versioning.
This means that the actual version number has 3 parts: `YEAR.MINOR.PATCH`. The `YEAR` is the current year, and the `MINOR`
and `PATCH` are calculated from the git history since the beginning of the current year.

*Note that the `MINOR` starts from `1` unlike in the traditional semantic versioning where it starts from `0`. This is
to start the new year with version `1` no matter if the severity of the commit. The primary reason is that it looks better
in the final software than `0`.*

## Usage

```yaml
# .github/workflows/version.yml
name: Semantic Calendar Version

on:
  push:
    branches:
      - master

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3
        with:
          ref: ${{ github.head_ref }}   # checkout the correct branch name
          fetch-depth: 0                # fetch the whole repo history

      - name: Semantic Calendar Version
        id: version
        uses: lukashornych/semantic-calendar-version@1.0.3

      - name: Use the version
        run: |
          echo ${{ steps.version.outputs.version }}
      - name: Use the previous version
        run: |
          echo ${{ steps.version.outputs.previous-version }}
```

### Mono-Repo

You can use semantic-calendar-version to version different modules in a mono-repo structure.
This can be achieved by using different `prefixes` and `log-path` filters for
different modules.

Assuming the following directory structure, we can use semantic-calendar-version to generate
version with prefix `module1-x.x.x` for changes in the `module1/` directory
and  `module2-x.x.x` for changes in the `module2/` directory.

```sh
.
├── Dockerfile
├── Makefile
├── README.md
├── module1
│   ├── Dockerfile
│   └── src/
└── module2
    ├── Dockerfile
    └── src/
```

With github actions you can create different workflows that are triggered
when changes happen on different directories.

```yaml
# .github/workflows/module1.yml
name: Version Module 1

on:
  pull_request:
    paths:
      - .github/workflows/module1.yml
      - module1/**
  push:
    paths:
      - .github/workflows/module1.yml
      - module1/**
    branches:
      - master

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3
        with:
          ref: ${{ github.head_ref }}   # checkout the correct branch name
          fetch-depth: 0                # fetch the whole repo history

      - name: Semantic Calendar Version
        uses: lukashornych/semantic-calendar-version@1.0.3
        with:
          prefix: module1-
          log-path: module1/
```

```yaml
# .github/workflows/module2.yml
name: Version Module 2

on:
  pull_request:
    paths:
      - .github/workflows/module2.yml
      - module2/**
  push:
    paths:
      - .github/workflows/module2.yml
      - module2/**
    branches:
      - master

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3
        with:
          ref: ${{ github.head_ref }}   # checkout the correct branch name
          fetch-depth: 0                # fetch the whole repo history

      - name: Semantic Calendar Version
        uses: lukashornych/semantic-calendar-version@1.0.3
        with:
          prefix: module2-
          log-path: module2/
```

## Versioning Model

Creates a version with the format `YEAR.MINOR.PATCH`

_To use this you need to be in the working dir of a git project:_
```
$ ./semantic-calendar-version
2024.1.0
```

Versions are incremented since the last tag or if new year comes. The patch version is incremented by default,
unless a new year came since last tag or there is at least one commit since the last tag, containing a minor identifier
(defaults to `/feat(\([^\)]+\))?:/`) in the message.

On branches other than the master/main and development branch (default to `master` and `dev`) the version is a variation
of the latest common tag with the master/main branch, and has the following format:

`{YEAR}.{MINOR}.{PATCH}-{sanitized-branch-name}.{commits-distance}.{hash}`

On the development branch the format is the following:

`{YEAR}.{MINOR}.{PATCH}-SNAPSHOT.{hash}`

_Example:_
```
---A---B---C <= Master (tag: 2024.1.1)     L <= Master (semantic-calendar-version: 2024.1.2)
            \                             /
             D---E---F---G---H---I---J---K <= Foo (semantic-calendar-version: 2024.1.2-foo.8.5e30d83)
```

_Example2 (with dev branch):_
```
---A---B---C <= Master (tag: 2024.1.1)     L <= Master (semantic-calendar-version: 2024.1.2)
            \                             / <= Fast-forward merges to master (same commit id)
             C                           L <= Dev (semantic-calendar-version: 2024.1.2-SNAPSHOT.5e30d83)
              \                         /
               E---F---G---H---I---J---K <= Foo (new_version: 2024.1.2-foo.7.5e30d83)
```

_Example3 (with feature message):_
```
---A---B---C <= Master (tag: 2024.1.1)     L <= Master (semantic-calendar-version: 2024.2.0)
            \                             /
             D---E---F---G---H---I---J---K <= Foo (semantic-calendar-version: 2024.2.0-foo.8.5e30d83)
                                         \\
                                         message: "feat: add magic button"
```

### Configuration

You can configure the action with various inputs, a list of which has been provided below:

| Name                  | Description                                                                                                                                                                                             | Default Value |
|-----------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------|
| tool-version          | The version of the tool to run                                                                                                                                                                          | latest        |
| release-branch        | The name of the master/main branch                                                                                                                                                                      | master        |
| dev-branch            | The name of the development branch                                                                                                                                                                      | dev           |
| hotfix-branch-pattern | The regex pattern for all hotfix branches                                                                                                                                                               | dev           |
| year_switch_mode      | Specifies when to switch to a new year. Possible values:<br/>  - Always - switches to a new year for all changes<br/>  - OnMinor - switches to a new year only for minor changes, not for patch changes | Always        |
| minor-identifier      | The string used to identify a minor release (wrap with '/' to match using a regular expression)                                                                                                         | feature:      |
| prefix                | The prefix used for the version name                                                                                                                                                                    |               |
| log-paths             | The paths used to calculate changes (comma-separated)                                                                                                                                                   |               |

## Requirements

To use this tool you will need to install a few dependencies:

Ubuntu:
```
sudo apt-get install \
  libevent-dev \
  git
```

Fedora:
```
sudo dnf -y install \
  libevent-devel \
  git
```

Alpine:
```
apk add --update --no-cache --force-overwrite \
  gc-dev pcre-dev libevent-dev \
  git
```

OsX:
```
brew install \
  libevent \
  git
```

## Build and Publish

To compile locally you need to install [crystal](https://crystal-lang.org/install/) and possibly
[all required libraries](https://github.com/crystal-lang/crystal/wiki/All-required-libraries).
Then you can run everything locally using the makefile.

To get the list of available commands:
```
$ make help
```

## Credits

This tool is heavily based on the [git-version](https://github.com/codacy/git-version) where all the versioning logic comes
from.

## License

semantic-calendar-version is available under the Apache 2 license. See the [LICENSE](./LICENSE) file for more info.