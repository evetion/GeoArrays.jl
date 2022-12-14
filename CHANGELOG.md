# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [unreleased]

### Added

- Subsample GeoArrays in plotting for performance. Use `scalefactor` to control this.

### Changed

- Changed `GeoArray` eltype to allow for Complex numbers.

### Fixed

- Profile tool works also for reversed lines


## [0.7.9] - 2022-10-15

### Added

- Added `coalesce` option for a GeoArray
- Added pre:and:post fixes to filenames, now supports netcdf and s3 like paths

### Fixed

- Fixed iterate specification so `sum` on a GeoArray is correct

[unreleased]: https://github.com/evetion/GeoArrays.jl/compare/v0.7.9...HEAD
[0.7.9]: https://github.com/evetion/GeoArrays.jl/compare/v1.0.0...v0.7.9
