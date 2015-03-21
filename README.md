
##Introduction

The Zephir API is a support service for Zephir, the HathiTrust metadata management system. 
The API is a Sinatra-based web API that allows access to data not available through
normal Zephir exports (e.g. pre-clustered item metadata for an object in the HathiTrust 
repository. This application is only meant to be run in the context of Zephir.

When available, the following content types are supported:

* XMl (text/xml)
* JSON (application/json)

## Readme and Information
* README (information about the code)
* API (information about the API provided by code)
* /docs (generated code documentation. See beloy

##Requirements

This code has been run and tested on Ruby 2.1 and Sinatra 1.4.5.

* Ruby 2.1+
* Sinatra 1.4.5+
* Bundler

For additional dependencies review the Gemfile.

## Installation

1. Install dependencies with bundler

```
bundle install
```

2. Start server

```
rackup
```

3. Setup database configuration file

/config/database.yml
```
test:
  adapter: sqlite3
  database: test/db/test.sqlite
```

## Tests

Tests are implemented with the default Ruby Minitest framework. 

```
rake test
```

### Generating Documentation
Comments are YARD compatible, but generated documentation is incomplete due to route extentions. 
This may be fixed in future versions of yard. YARD style tags are used and there is a .yardopts 
file for preferences. 

```
yardoc
```

##License

See [LICENSE](LICENSE).

##Support

This software is not meant to be run outside the context of the Zephir metadata management system. 
Tthe running service instance is supported as part of Zephir.
