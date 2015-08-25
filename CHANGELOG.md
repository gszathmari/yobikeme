## v1.5.2 (2015-08-26)

  - Improve unit test coverage

## v1.5.1 (2015-08-26)

  - Amending exception handling logic

## v1.5.0 (2015-08-26)

  - Add Rollbar support
  - Log errors with Keen
  - Some refactoring around logging
  - Improve unit test coverage
  - Add friendly error response to the end user if upstream API fails
  - Bluemix deployment script is broken, removing for now

## v1.4.0 (2015-08-25)

  - Add optional Keen.io support for event logging
  - Fixing minor bug when stations is not returned from upstream API
  - Activate Redis and minor change in Travis file
  - Adding keywords to package.json file
  - Surpress git error message in Travis

## v1.3.0 (2015-08-21)

  - Only return walking directions to stations with bikes available
  - Minor bugfix in unit test code

## v1.2.1 (2015-08-21)

  - Improve unit test coverage
  - Improve Redis related code in Stations model a bit

## v1.2.0 (2015-08-19)

  - Fixing Newrelic support
  - Code refactoring in models: simplifying the Station model
  - Fixing minor issue with Gruntfile
  - Add /version and /hash endpoints

## v1.1.1 (2015-08-19)

  - Return error if username is not supplied with the API call

## v1.1.0 (2015-08-19)

  - Switching to IBM BlueMix hosting from OpenShift

## v1.0.1 (2015-08-18)

  - Replace `request` module with `yo-api2`
  - Fixing bug affecting Redis when running unit tests

## v1.0.0 (2015-08-17)

  - Initial release
