# Yo Bike Me (yobikeme)

[![Build Status](https://travis-ci.org/gszathmari/yobikeme.svg)](https://travis-ci.org/gszathmari/yobikeme)
[![Coverage Status](https://coveralls.io/repos/gszathmari/yobikeme/badge.svg?branch=master&service=github)](https://coveralls.io/github/gszathmari/yobikeme?branch=master)
[![Dependency Status](https://david-dm.org/gszathmari/yobikeme.svg)](https://david-dm.org/gszathmari/yobikeme)

Yo the `yobikeme` user and it will send you the nearest cycle hire station

## Configuration

The following environmental variables should be configured
- `YO_API_TOKEN`: Yo API token
- `YOBIKEME_HELP`: (optional) Link to YOBIKEME help page
- `WORKERS`: (optional) Number of workers to handle requests
- `NEW_RELIC_LICENSE_KEY`: (optional) NewRelic licence key
- `REDIS_HOST`: (default: 127.0.0.1) Redis server address
- `REDIS_PORT`: (default: 6379) Redis server port
- `REDIS_PASSWORD`: Redis credentials
- `LOGENTRIES_TOKEN`: (optional) Logentries token
