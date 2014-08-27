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
#### 1) You will need to configure your swift credentials

```ruby
NightcrawlerSwift.configure({
  bucket: "rogue",
  tenant_name: "nightcrawler"
  username: "my_username1",
  password: "my_password1",
  auth_url: "https://auth.url.com:123/v2.0/tokens"
})
```

_You could create an initializer with this code_

#### 2) Load rake tasks into your Rakefile

```ruby
require 'nightcrawler_swift'
load 'nightcrawler_swift/tasks/asset_sync.rake'
```

#### 3) Profit!

```sh
rake nightcrawler_swift:rails:asset_sync
```

It will invoke ```rake assets:precompile``` and will copy your public directory to swift bucket/container.

### Programatically

#### 1) Configure

Repeat the first step of Rails guide

#### 2) Call method sync with the desired directory

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
