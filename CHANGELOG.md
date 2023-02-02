# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.7.13] - 2023-01-12
- Added convert, affine!
- Added broadcast for GeoArray, so `ga .+ 1` isa `GeoArray`

## [0.7.12] - 2023-01-12
- Fix interpolation, update to GeoStatsSolvers
- Fix indexing bug in non-singleton sized GeoArrays

## [0.7.11] - 2023-01-09
- Update compat bounds to use ArchGDAL 0.10

## [0.7.10] - 2022-12-14

### Added
- Add profile tool to sample raster values.
- Subsample GeoArrays in plotting for performance. Use `scalefactor` to control this.

### Changed

- Changed `GeoArray` eltype to allow for Complex numbers.

## [0.7.9] - 2022-10-15

### Added

- Added `coalesce` option for a GeoArray
- Added pre:and:post fixes to filenames, now supports netcdf and s3 like paths

### Fixed

- Fixed iterate specification so `sum` on a GeoArray is correct

[unreleased]: https://github.com/evetion/GeoArrays.jl/compare/v0.7.13...HEAD
[0.7.13]: https://github.com/evetion/GeoArrays.jl/compare/v0.7.12...v0.7.13
[0.7.12]: https://github.com/evetion/GeoArrays.jl/compare/v0.7.11...v0.7.12
[0.7.11]: https://github.com/evetion/GeoArrays.jl/compare/v0.7.10...v0.7.11
[0.7.10]: https://github.com/evetion/GeoArrays.jl/compare/v0.7.9...v0.7.10
[0.7.9]: https://github.com/evetion/GeoArrays.jl/compare/v0.7.8...v0.7.9
