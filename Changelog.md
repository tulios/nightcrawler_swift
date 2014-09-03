# Changelog

## 0.4.0

  - Better catalog selection
  - Treatment for no catalogs returned
  - Splited asset_sync task in two other tasks: sync and asset_sync
  - Configurable verify_ssl and timeout
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
