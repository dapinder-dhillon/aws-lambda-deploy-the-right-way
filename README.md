# TDMP AWS Lambda File Distribution with Python

TDMP File distribution lambda is written in `python` and as a best practice, we are ensuring using the python virtual environment.
Virtualenv keeps your Python packages in a virtual environment localized to your project, instead of forcing you to install
your packages system-wide.
There are a number of benefits to this,

- the first and principle one is that you can have multiple virtulenvs, so you can have multiple sets of packages that
 for different projects, even if those sets of packages would normally conflict with one another.
- the second, make it easy for you to release your project with its own dependent modules.
- the third, is that it allows you to switch to another installed python interpreter for that project.

In the past, we have used [pipenv](https://pipenv.pypa.io/en/latest/) as a virtual environment and dependency management tool.
This project is using [poetry](https://python-poetry.org/) which is similar to Pipenv. In addition, it also provides
package management functions, such as packaging and publishing. You can think of it as a superset of Pipenv.

:point_right: If you are new to python virtual environment and dependency management, this [Python Workshop](https://elsevier.atlassian.net/wiki/spaces/TIOCDT/pages/119600976384311/Python+Workshop+Link)
could be useful to you.

## Basic Poetry Usage
> Refer poetry official documentation for full details

### Create Virtual Env (or install dependencies)
```shell
$ poetry install
```

### Activate Virtual Env
```shell
$ poetry run python lambda_file_distribution/file_distribution_lambda.py
```

### Tracking & Update Package
```shell
$ poetry show
$ poetry show --outdated
$ poetry update
$ poetry update --without dev # without dev dependencies mentioned in pyproject.toml
```

> If there is a need to add any new external dependency like existing `requests` being used, you should either add a package
> using `poetry add` or manually update [pyproject.toml](./pyproject.toml)

## AWS Lambda Deployment Using Layers
Developers generally import libraries and dependencies into their AWS Lambda functions like `requests` being used in [file_distribution_lambda.py](./lambda_file_distribution/file_distribution_lambda.py).
While you can zip these dependencies as part of the build and deployment process, in many cases it’s easier to use layers instead.
Lambda layers provide a convenient and effective way to package code libraries for sharing with Lambda functions.
Using layers can help reduce the size of uploaded archives and make it faster to deploy your code. As a bonus, since it
reduces the size of deployment, you can view lambda code on the Lambda AWS console.

TDMP File distribution lambda has been deployed using layers:
- The python project dependencies are being executed vua terraform using poetry in a docker container.
- The dependencies then are being zipped and are uploaded as lambda layer using terraform [here](./terraform/lambda_dependencies_layer)
- The dependencies are uploaded ONCE per AWS account so that all TDMP File distribution lambdas deployed per each environment
  (labs, sit, dev etc) can use the same dependency.

For more details check AWS documentation like [this](https://aws.amazon.com/blogs/compute/using-lambda-layers-to-simplify-your-development-process/)
or there are loads of documentation online in and outside of AWS.

:point_right: TIODI explained the Lambda Layer, its use and advantage in the bi-weekly technical demo. Check the recording details below:
- Meeting Recording: [Zoom](https://elsevier.zoom.us/rec/share/Ew6zxLaf5lL8tLsJ8jC4RHv2WqV1lgVCysn_8cUmBQSaFG3zdBCB2MiNY9ZxgTJ4.m05om8cPEm14CHbO?startTime=1662458319000)
- Passcode: `FvY3Pq+b`


<!-- Below pre-commit information should be retained in all repos.  -->
## Using Pre-Commit Hooks
Git hook scripts are useful for identifying simple issues before submission to code review.We run our hooks on every commit
to automatically point out issues in code such as missing semicolons, trailing whitespace, and debug statements. By pointing
these issues out before code review, this allows a code reviewer to focus on the architecture of a change while not wasting
time with trivial style nitpicks.

### Pre-Requisite
Below are the list of pre-requisites/tools which are being referred/used in [.pre-commit-config.yaml](.pre-commit-config.yaml).
The pre-commit under the hood executes/uses below tools to validate the code.

- [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [terraform-docs](https://github.com/terraform-docs/terraform-docs#installation)
- [pre-commit](https://pre-commit.com/#intro)
- [tflint](https://github.com/terraform-linters/tflint#installation)
- [shellcheck](https://github.com/koalaman/shellcheck#installing)
- [Gitleaks](https://github.com/zricethezav/gitleaks#as-a-pre-commit-hook)

### Usage
Below command will install the [pre-commit](https://pre-commit.com/#intro) to your `.git/hooks/pre-commit`.
Once installed all the rules mentioned in [.pre-commit-config.yaml](.pre-commit-config.yaml) will get validated during `git commit`
```bash
pre-commit install
```

It's usually a good idea to run the hooks against all of the files (usually pre-commit will only run on the changed files during git hooks).

```bash
pre-commit run --all-files
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Code Release Management
This project is using fully automated code release management to progressive environments like UAT, SIT, PROD etc. using
[semantic versioning](https://semver.org/) and [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/).

### Semantic Versioning
Given a version number MAJOR.MINOR.PATCH (e.g. v1.4.2), increment the:
1. **MAJOR** version when you make incompatible API changes,
2. **MINOR** version when you add functionality in a backwards compatible manner, and
3. **PATCH** version when you make backwards compatible bug fixes.
   Semantic Release has always been an industry standard and conventional commits allows to take this a step further to automated
   the version number based on the commit message.

> IMPORTANT: :information_source: All commit messages made to the repository should conform to the conventional commit message format.
The commit contains the following structural elements, to communicate intent to the consumers of your library:

### Conventional commits
1. **fix:** a commit of the type fix patches a bug in your codebase (this correlates with PATCH in semantic versioning).
2. **feat:** a commit of the type feat introduces a new feature to the codebase (this correlates with MINOR in semantic versioning).
3. **BREAKING CHANGE:** a commit that has a footer BREAKING CHANGE:, or appends a ! after the type/scope, introduces a breaking API change (correlating with MAJOR in semantic versioning). A BREAKING CHANGE can be part of commits of any type.
4. types other than **fix:** and **feat:** are allowed, for example _chore:, ci:, docs:, style:, refactor:, perf:, test:_.
