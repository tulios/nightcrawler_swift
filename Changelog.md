# Changelog

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
