# Changelog

## 0.10.1

  - Exclude ```Expires``` header

## 0.10.0

  - Added support for custom headers

## 0.9.0

  - Added support for content-encoding option
  - CLI also supports --content-encoding option

## 0.8.1

  - Ensure connected on url getters `catalog, admin_url, upload_url, public_url, internal_url` (pull request #28)

## 0.8.0

  - Added support for ssl_version configuration
  - Command for object metadata. Available for cli (closes #16, #17)

## 0.7.0

  - CLI now supports ```--no-cache``` which ignores the cached connection and removes the cache file if it exists (issue #12)
  - Bugfix: invalidate nswift_cache when the connection fail (issue #27)
  - Bugfix: OpenStruct in Ruby 1.9.x doesn't have the method [], using 'send' instead
  - Bugfix: OpenStruct and nil doesn't have the method to_h in Ruby 1.9.x

## 0.6.0

  - Upload command allows a custom max-age (issue #23)
  - List command allows the following parameters: ```limit```, ```marker```, ```end_marker```, ```prefix```, ```format```, ```delimiter``` and ```path``` (issue #22)
  - Download command uses the internal_url by default (issue #25)
  - CLI now supports a ```--max-age``` to override the default max_age
  - Included ```Expires``` header to upload command based on max_age configuration (issue #9)
  - The _password_ option can be defined by the env variable ```NSWIFT_PASSWORD``` (issue #21)
  - Support for SSL Client Certificates through the options: ```ssl_client_cert```, ```ssl_client_key``` and ```ssl_ca_file```
  - Configurable ```internal_url```

## 0.5.0

  - CLI now supports ```-b/--bucket``` to override the default bucket/container (issue #10)
  - CLI command for printing the public url of a given path (issue #18)
  - CLI better treatment for errors and invalid commands
  - Bugfix: CLI when receives a invalid command doesn't shows that it is an invalid command (issue #20)
  - Configurable ```admin_url``` and ```public_url``` (issue #14)
  - Included "public" directive in ```Cache-Control``` header
  - Each request will retry X times before failing, the number of retries and the max waiting time can be configured through options

## 0.4.0

  - Better catalog selection
  - Treatment for no catalogs returned
  - Splited asset_sync task in two other tasks: ```sync``` and ```asset_sync```
  - Configurable ```verify_ssl``` and ```timeout```
  - Automatic connect/reconnect of commands
  - Bugfix: download command was not using the bucket/container name
  - Bugfix: the etag header must not be quoted
  - CLI with basic commands (list, download, upload and delete)

## 0.3.0

  - Included ```Cache-Control``` header to upload command through max_age configuration parameter
  - Sending etag when uploading assets
  - Bugfix: rake task now returns exit code 1 when error

## 0.2.3

  - Removed rest-client version due to compatibility issues

## 0.2.2

  - Included ```Content-Type``` header to upload command

## 0.2.1

  - Bugfix: sync was not connecting

## 0.2.0

  - Better Rails integration
  - Download command

## 0.1.1

  - Bugfix: sync broken syntax

## 0.1.0

  - Connection object
  - Sync, upload, delete and list commands
  - Rake task to sync Rails public dir
