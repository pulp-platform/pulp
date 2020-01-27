# Tests
You can run tests either locally in a manual fashion or use your GitLab CI
instance. The latter is meant for internal usage.

## Running software tests manually
Call the `./update-tests` script in the top-level directory. This populate this
directory with all software tests.

Make sure you have [configured](https://github.com/pulp-platform/pulp-sdk) your
SDK. You can now run single tests by using the provided Makefiles or use
`plptest --testset path-to-testset.cfg`. Other useful flags you can set for
`plptest` are `--stdout` to dump the output to stdout and `--threads` to run
multiple tests at once.

After the tests complete you will have JUnit reports for each `testset.cfg`
placed in the `junit-reports` directory.

## Adding your own tests
You can add your own tests by putting them in a repository and adding them to
`update-tests` and `update-tests-gitlab` scripts in the top-level folder. Make
sure you define an appropriate `testset.cfg` that lists all the tests in your
repository and for each test provide another `testset.cfg` with instructions on
how to run it. Have a look at the already existing tests for an idea how such
files should look like.

## Setting up CI
A brief explanation on how to set up GitLab CI for this project.

### Prerequisites
- Questasim accessible from the GitLab instance
- Vivado accessible from the GitLab instance
- Access to the ETH Artifactory server. This is required to download the PULP
  SDK release versions. Alternatively, you can also always fetch the latest SDK
  sources and let it be built and used for running the tests. This approach is
  not recommended.
- Centos7 runners

### Steps
1. Import this repository to GitLab. Using the GitLab import functionality is
   recommended.
2. Under Settings -> Repository -> Variables add the following environment
   variables:
   - `ARTIFACTORY_USER`
   - `ARTIFACTORY_PASSWORD`
   - `PULP_ARTIFACTORY_USER`
   - `PULP_RUNTIME_GCC_TOOLCHAIN`

   with their respective values. Make sure you check the mask tick box on all of
   these.

   This is a redundant set of variables for backward compatibility reasons
3. The `.gitlab-ci.yml` file should be auto-detected by GitLab and start running
   test instances whenever you push commits.
4. Inspect the current running tests instances (pipelines) under CI/CD ->
   Pipelines. Here you can stop instances you deem unnecessary but you can also
   launch such manually for any branch by using the green `Run Pipeline` button.

### Artifacts and Reports
Test instances produce a set of outputs called artifacts and reports. They can
be downloaded from the GitLab interface.

Reports are `JUnit.xml` documents and for convenience HTML renderings
thereof. These are used to inspect test results.

Artifacts are more general byproducts of the different execution stages of a
pipeline. In this repository each stage saves nearly all its relevant output.
While these artifacts can be used for debugging, what you mostly want is
inspecting the FPGA build results (bitstream, reports).



