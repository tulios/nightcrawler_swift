# Changelog

## 0.6.0 (work in progress)

  - Upload command allows a custom max-age (issue #23)
  - List command allows the following parameters: ```limit```, ```marker```, ```end_marker```, ```prefix```, ```format```, ```delimiter``` and ```path``` (issue #22)
  - CLI now supports a ```--max-age``` to override the default max_age
  - Included ```Expires``` header to upload command based on max_age configuration (issue #9)
  - The _password_ option can be defined by the env variable ```NSWIFT_PASSWORD``` (issue #21)
  - Support for SSL Client Certificates through the options: ```ssl_client_cert```, ```ssl_client_key``` and ```ssl_ca_file```

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
