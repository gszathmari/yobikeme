# YOBIKEME (Yo Bike Me)

Double-tap the [YOBIKEME](http://justyo.co/YOBIKEME) user and it will send you the walking directions to the nearest cycle hire station

[![Build Status](https://travis-ci.org/gszathmari/yobikeme.svg)](https://travis-ci.org/gszathmari/yobikeme)
[![Coverage Status](https://coveralls.io/repos/gszathmari/yobikeme/badge.svg?branch=master&service=github)](https://coveralls.io/github/gszathmari/yobikeme?branch=master)
[![Dependency Status](https://david-dm.org/gszathmari/yobikeme.svg)](https://david-dm.org/gszathmari/yobikeme)

## Supported Cities

The latest list of supported cities is available on [CityBikes](http://citybik.es)

## Configuration

The following environmental variables should be configured

### General

- `YO_API_TOKEN`: Yo API secret token
- `REDIS_HOST`: _(default: 127.0.0.1)_ Redis server address
- `REDIS_PORT`: _(default: 6379)_ Redis server port
- `REDIS_PASSWORD`: _(optional)_ Redis credentials
- `HOST`: _(optional)_ Bind host
- `PORT`: _(optional)_ Bind port
- `YOBIKEME_HELP`: _(default: bit.ly/yobikeme-help)_ Link to YOBIKEME help page
- `WORKERS`: _(default: 1)_ Number of workers to handle Yo requests

### Monitoring

- `NEW_RELIC_LICENSE_KEY`: _(optional)_ NewRelic licence key
- `LOGENTRIES_TOKEN`: _(optional)_ Logentries secret token
- `KEEN_PROJECT_ID`: _(optional)_ Keen.io project ID for event logging
- `KEEN_WRITE_API_KEY`: _(optional)_ Keen.io write API key
- `ROLLBAR_ACCESS_TOKEN`: _(optional)_ Rollbar server-side token for logging uncaught exceptions

## Testing

Execute test suite:

```
grunt test
```

## Contribute

Pull requests are welcome

Check [CONTRIBUTE.md](CONTRIBUTE.md) for more details

### Contributors

- [Gabor Szathmari](http://gaborszathmari.me) - [@gszathmari](https://twitter.com/gszathmari)

## Credits

* [CityBikes API](http://api.citybik.es/v2/)
* [BarRecommendor](https://github.com/YoApp/BarRecommendor)

## License

See the [LICENSE](LICENSE) file for license rights and limitations (MIT)
