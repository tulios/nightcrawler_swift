# Nightcrawler Swift [![Gem Version](https://badge.fury.io/rb/nightcrawler_swift.svg)](http://badge.fury.io/rb/nightcrawler_swift) [![Code Climate](https://codeclimate.com/github/tulios/nightcrawler_swift/badges/gpa.svg)](https://codeclimate.com/github/tulios/nightcrawler_swift) [![Travis](https://api.travis-ci.org/tulios/nightcrawler_swift.svg?branch=master)](https://travis-ci.org/tulios/nightcrawler_swift)

Like the X-Men nightcrawler this gem teleports your assets to a OpenStack Swift bucket/container. It was designed to sync your assets with OpenStack Swift and allow some operations with your buckets/containers.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nightcrawler_swift'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install nightcrawler_swift
```

## Usage

* [With Rails](https://github.com/tulios/nightcrawler_swift#with-rails)
* [Programatically](https://github.com/tulios/nightcrawler_swift#programatically)
* [Command Line](https://github.com/tulios/nightcrawler_swift#command-line)

### With Rails
#### 1) Configure your swift credentials and options

_In config/application.rb_ or _config/environments/*.rb_

```ruby
config.nightcrawler_swift.bucket = "rogue"
config.nightcrawler_swift.tenant_name = "nightcrawler"
config.nightcrawler_swift.username = "my_username1"
config.nightcrawler_swift.password = "my_password1"
config.nightcrawler_swift.auth_url = "https://auth.url.com:123/v2.0/tokens"
```

The __password__ option can be left blank and be defined by the env variable __NSWIFT_PASSWORD__. The env variable will take precedence if the option was set.

__Optional configurations:__

```ruby
config.nightcrawler_swift.max_age = 3600 # default: nil
config.nightcrawler_swift.timeout = 10 # in seconds, default: nil

# default: uses the admin_url returned by authentication
config.nightcrawler_swift.admin_url = "https://api.host.com/v1/AUTH_1234"

# default: uses the public_url returned by authentication
config.nightcrawler_swift.public_url = "http://asset.host.com/v1/AUTH_1234"

# default: 5, to disable set it to false
config.nightcrawler_swift.retries = 3

# in seconds, default: 30
config.nightcrawler_swift.max_retry_time = 64

# default: false. You could use OpenSSL::SSL::VERIFY_PEER
config.nightcrawler_swift.verify_ssl = true

# default: nil
config.nightcrawler_swift.ssl_client_cert =
  OpenSSL::X509::Certificate.new(File.read("cert.pem"))

# default: nil
config.nightcrawler_swift.ssl_client_key =
  OpenSSL::PKey::RSA.new(File.read("key.pem"), "passphrase, if any")

# default: nil
config.nightcrawler_swift.ssl_ca_file = "ca_certificate.pem"
```

By default it will use ```Rails.logger``` as logger, to change that use a different logger in configurations, like:

```ruby
config.nightcrawler_swift.logger = Logger.new(STDOUT)
```

##### further explanation of configurations

> max_age

It will be used to define *Cache-Control:max-age=<value>* header.

> retries

The number of times to retry the request before failing. To disable this feature set it to __false__.

> max_retry_time

Maximum delay in seconds between each retry. The delay will start with 1s and will double for each retry until this value.

#### 2) Profit!

```sh
$ rake nightcrawler_swift:rails:asset_sync
```

It will invoke ```rake assets:precompile``` and will copy your public directory to swift bucket/container. To sync the public directory without the asset precompilation use the task: ```nightcrawler_swift:rails:sync```

### Programatically

#### 1) Configure your swift credentials and options

```ruby
NightcrawlerSwift.configure({
  bucket: "rogue",
  tenant_name: "nightcrawler",
  username: "my_username1",
  password: "my_password1",
  auth_url: "https://auth.url.com:123/v2.0/tokens"
})
```

The __password__ option can be left blank and be defined by the env variable __NSWIFT_PASSWORD__. The env variable will take precedence if the option was set.


__Optional configurations:__

```ruby
max_age: 3600,
timeout: 10, # in seconds

# default: uses the admin_url returned by authentication
admin_url: "https://api.host.com/v1/AUTH_1234",

# default: uses the public_url returned by authentication
public_url: "http://asset.host.com/v1/AUTH_1234",

# default: 5, to disable set it to false
retries: 3,

# in seconds, default: 30
max_retry_time: 64

# default: false. You could use OpenSSL::SSL::VERIFY_PEER
verify_ssl: true,

# default: nil
ssl_client_cert:
  OpenSSL::X509::Certificate.new(File.read("cert.pem")),

# default: nil
ssl_client_key:
  OpenSSL::PKey::RSA.new(File.read("key.pem"), "passphrase, if any"),

# default: nil
ssl_ca_file: "ca_certificate.pem"
```

By default it will use ```Logger.new(STDOUT)``` as logger, to change that use:

```ruby
NightcrawlerSwift.logger = Logger.new(StringIO.new)
```

#### 2) Use method sync with the desired directory

```ruby
NightcrawlerSwift.sync File.expand_path("./my-dir")
```

### Command Line

The NightcrawlerSwift shell command (CLI) allows you to interact with your buckets/containers easily, it has the same commands of the gem. To see the help, use the cli without arguments or use the _-h_/_--help_ switch.

```sh
$ nswift # or nswift -h
```

```nswift``` will use the configurations stored at the file __.nswiftrc__ located at your home directory. If you try to use any command without the file, it will create a sample configuration for you, but you can create your own.

The configuration is a __json__ file, named __.nswiftrc__. You can include any configuration available to the gem (see the other usages example to know each option available). Follow the format:

```json
{
  "bucket": "<bucket/container name>",
  "tenant_name": "<tenant name>",
  "username": "<username>",
  "password": "<password>",
  "auth_url": "<auth url, ex: https://auth.url.com:123/v2.0/tokens>"
}
```

The following commands are available through the cli:

```sh
$ nswift list
```
```sh
$ nswift upload <real_path> <swift_path> # nswift upload robots.txt assets/robots.txt
```

Upload also supports a custom max-age, to override the value defined in ".nswiftrc", example:

```sh
$ nswift upload <real_path> <swift_path> --max-age VALUE # nswift upload readme assets/readme.md --max-age 300
```

```sh
$ nswift download <swift_path> # nswift download assets/robots.txt > my-robots.txt
```
```sh
$ nswift delete <swift_path> # nswift delete assets/robots.txt
```
```sh
$ nswift url-for <swift_path> # nswift url-for assets/robots.txt
```

For any commands you could provide a different configuration file through the _-c_/_--config_ switch, as:

```sh
$ nswift list -c /dir/my-nswift-rc
```

and a different bucket/container name through the _-b_/_--bucket_ switch, as:

```sh
$ nwift list -b rogue
```

## Commands

NightcrawlerSwift has some useful built-in commands. All commands require the configuration and will __automatically__ connect/reconnect to keystone when necessary.

### Upload

```ruby
upload = NightcrawlerSwift::Upload.new
upload.execute "my_file_path.txt", File.open("../my_file_fullpath.txt", "r")
# true / false
```

_This upload command was not designed to send very large files_.

It will accept a custom max-age, overriding the configured value through ```NightcrawlerSwift.configure```, example:

```ruby
upload = NightcrawlerSwift::Upload.new
upload.execute "readme", File.open("readme.md", "r"), max_age: 300
# true / false
```

### Download

```ruby
download = NightcrawlerSwift::Download.new
download.execute "my_file_path.txt"
# File content
```

_This download command was not designed to retrieve very large files_

### List

```ruby
list = NightcrawlerSwift::List.new
list.execute
# [{"hash": "...", "name": "my_file_path.txt"}, {}, {}, ...]
```

This command supports the following parameters: __limit, marker, end_marker, prefix, format, delimiter, path__

Example:

```ruby
list = NightcrawlerSwift::List.new
list.execute prefix: '/some/path'
# [{"hash": "...", "name": "/some/path/with/my_file_path.txt"}, {}, {}, ...]
```

### Delete

```ruby
delete = NightcrawlerSwift::Delete.new
delete.execute "my_file_path.txt"
# true / false
```

### Sync

```ruby
sync = NightcrawlerSwift::Sync.new
sync.execute "/dir/to/synchronize"
```

## Connection

To manually establish the connection with keystone, use:

```ruby
NightcrawlerSwift.connection.connect!
```

To check if the connection is still valid, use:

```ruby
NightcrawlerSwift.connection.connected?
```

To reconnect just use ```NightcrawlerSwift.connection.connect!``` again.

## Options

After configure the NightcrawlerSwift you can access your configurations through the __options__ method, like:

```ruby
NightcrawlerSwift.options
```

The only difference is that you will access each configuration as a method instead of a hash style, like:

```ruby
NightcrawlerSwift.configure tenant_name: "rogue"

# Can be used as:
NightcrawlerSwift.options.tenant_name # "rogue"
```

## Contributing

1. Fork it ( https://github.com/tulios/nightcrawler_swift/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
