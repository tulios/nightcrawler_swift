[![Code Climate](https://codeclimate.com/github/tulios/nightcrawler_swift/badges/gpa.svg)](https://codeclimate.com/github/tulios/nightcrawler_swift)

# Nightcrawler Swift

Like the X-Men nightcrawler this gem teleports your assets to a OpenStack Swift bucket/container. It was designed to sync your assets with OpenStack Swift and allow some operations with your buckets/containers.

## Installation

Add this line to your application's Gemfile:

    gem 'nightcrawler_swift'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nightcrawler_swift

## Usage

### With Rails
#### 1) Configure your swift credentials

_In config/application.rb_ or _config/environments/*.rb_

```ruby
config.nightcrawler_swift.bucket = "rogue"
config.nightcrawler_swift.tenent_name = "nightcrawler"
config.nightcrawler_swift.username = "my_username1"
config.nightcrawler_swift.password = "my_password1"
config.nightcrawler_swift.auth_url = "https://auth.url.com:123/v2.0/tokens"
```

By default it will use ```Rails.logger``` as logger, to change that use a different logger in configurations, like:

```ruby
config.nightcrawler_swift.logger = Logger.new(STDOUT)
```

#### 2) Profit!

```sh
rake nightcrawler_swift:rails:asset_sync
```

It will invoke ```rake assets:precompile``` and will copy your public directory to swift bucket/container.

### Programatically

#### 1) Configure your swift credentials

```ruby
NightcrawlerSwift.configure({
  bucket: "rogue",
  tenant_name: "nightcrawler"
  username: "my_username1",
  password: "my_password1",
  auth_url: "https://auth.url.com:123/v2.0/tokens"
})
```

By default it will use ```Logger.new(STDOUT)``` as logger, to change that use:

```ruby
NightcrawlerSwift.logger = Logger.new(StringIO.new)
```

#### 2) Use method sync with the desired directory

```ruby
NightcrawlerSwift.sync File.expand_path("./my-dir")
```

## Commands

NightcrawlerSwift has some useful built-in commands. All commands require the configuration and a established connection.

To Establish the connection, use:

```ruby
NightcrawlerSwift.connection.connect!
```

To check if the connection is still valid, use:

```ruby
NightcrawlerSwift.connection.connected?
```

To reconnect just use ```NightcrawlerSwift.connection.connect!``` again.

### Upload

```ruby
upload = NightcrawlerSwift::Upload.new
upload.execute "my_file_path.txt", File.open("../my_file_fullpath.txt", "r")
# true / false
```

_This upload command was not designed to send very large files_

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

### Delete

```ruby
delete = NightcrawlerSwift::Delete.new
delete.execute "my_file_path.txt"
# true / false
```

## Contributing

1. Fork it ( https://github.com/tulios/nightcrawler_swift/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
