## 1.5.10 (2015-09-22)

  - Add geofencing support
  - Force Citi bikes instead of Hudson Bike Shares in the Manhattan area

## v1.5.9 (2015-09-11)

  - Faster response time if the nearest cycle hire network is too far
  - Use 'forever' to run node in production

## v1.5.8 (2015-09-10)

  - Adding morgan to log HTTP requests onto console

## v1.5.7 (2015-09-05)

  - Log user coordinates in case of error for debugging purposes

## v1.5.6 (2015-09-03)

  - Add AWS ECS task definition
  - Add Docker compose configuration file
  - Fix Dockerfile to serve /version endpoint again

## v1.5.5 (2015-09-02)

  - Add Docker support

## v1.5.4 (2015-08-27)

  - Fixing automated Bluemix deployments

## v1.5.3 (2015-08-27)

  - Input validate incoming parameters

## v1.5.2 (2015-08-26)

  - Improve unit test coverage
  - Minor code refactoring in controllers

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
