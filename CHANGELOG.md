# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [0.12.0] - [XXXX-XX-XX]
### Added
- EligibilityData#errors
- EligibilityData#errors?

## [0.11.0] - [2020-04-24]
### Added
- EligibilityData#medicare?
- EligibilityData#plan\_id
- EligibilityData#plan?
- EligibilityBenefits#where\_not
- EligibilityBenefits#+
- EligibilityBenefit#additional\_info
- EligibilityBenefit#descriptions

### Changed
- EligibilityData initialize now checks for sub-classes of EligibilityBenefits with trading partner
- EligibilityData initialize now checks for sub-classes of EligibilityBenefits with trading partner responds to `factory` to choose sub-class
- EligibilityBenefits initializes `self.class` type in case it's a subclass

## [0.10.0] - [2020-04-09]
### Added
- Add Trading Partner API querying capability
- Request::TradingPartner
- Response::TradingPartnerData
- Response::TradingPartnersData
- Models::TradingPartner

## [0.9.0] - [2020-04-08]
### Added
- Added EligibilityBenefit#medicare?
- Added EligibilityData#medicare?

### Changed
- EligibilityBenefit(s)#individual returns true for medicare in benefit and queries that look for 'IND'
- EligibilityBenefit(s)#in\_network returns true for medicare in benefit and queries that look for 'Y'

## [0.8.0] - [2020-04-04]
### Changed
- Attempt to serialize all properties with 'date' in the name to ChangeHealth date format

## [0.7.0] - [2020-04-03]
### Changed
- Fixed bug in serializing date on subscriber and encounter

## [0.6.0] - [2020-04-02]
### Changed
- Added Indifferent Access to hashes
- Fixed bug with Authentication endpoint

## [0.5.0] - [2020-03-11]
### Added
- EligibilityBenefit Deductible information
- EligibilityBenefit benefits date information
- EligibilityBenefit(s) child
- EligibilityBenefit(s) employee
- EligibilityBenefit(s) family
- EligibilityBenefit(s) employee and child

### Changed
- Broke EligibilityBenefit and EligibilityBenefits into separate files

## [0.4.0] - [2020-03-10]
### Added
- EligibilityBenefit(s) Employee information
- EligibilityData plan date information
- EligibilityData eligibility, plan and service date helpers on date info

## [0.3.0] - [2020-03-09]
### Added
- Production endpoint

## [0.2.0] - [2020-03-09]
### Added
- EligibilityData
- EligibilityBenefit
- EligibilityBenefits

### Changed
- Eligibility.query returns EligibilityData object

## [0.1.0] - 2020-03-04
### Added
- Provider
- Subscriber
- Encounter
- Eligibility
- Authentication
- Configuration

[0.11.0]: https://github.com/WeInfuse/change_health/compare/v0.10.0...v0.11.0
[0.10.0]: https://github.com/WeInfuse/change_health/compare/v0.9.0...v0.10.0
[0.9.0]: https://github.com/WeInfuse/change_health/compare/v0.8.0...v0.9.0
[0.8.0]: https://github.com/WeInfuse/change_health/compare/v0.7.0...v0.8.0
[0.7.0]: https://github.com/WeInfuse/change_health/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/WeInfuse/change_health/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/WeInfuse/change_health/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/WeInfuse/change_health/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/WeInfuse/change_health/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/WeInfuse/change_health/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/WeInfuse/change_health/compare/v0.1.0
