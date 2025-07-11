# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

# [6.1.2] - 2025-07-02

Updates ChangeHealth Response error message to return description if field is not found instead of previous behaviour returning nil.

# [6.1.1] - 2025-01-30

### Bug Fix

* Fixed bug when dates on 835 reports were ""

# [6.1.0] - 2025-01-24

### Added

* `Report835ServiceLine#service_date`
* `Report835ServiceLine#service_date_begin`
* `Report835ServiceLine#service_date_end`

# [6.0.0] - 2024-11-22

Previously the only field extracted from the `informationStatuses` section of the 277 report JSON was `healthCareClaimStatusCategoryCode`. This version includes the following additional fields from this section: `healthCareClaimStatusCategoryCodeValue`, `statusCode` & `statusCodeValue`.

### Removed

Breaking changes:

* `Report277InfoClaimStatus#status_category_codes`
* `Report277InfoClaimStatus#add_status_category_code`

### Added

* `ChangeHealth::Response::Claim::Report277InfoStatus` model that encapsulates the fields listed above.
* `Report277InfoClaimStatus#info_statuses` property that stores all `Report277InfoStatus` found in the `informationStatuses` section of the 277 JSON.
* `Report277InfoClaimStatus#add_info_status` method to add individual `Report277InfoStatus`.
* `Report277Data#latest_info_statuses` method to return the latest `informationStatuses` in the 277 JSON. See README for usage.

# [5.18.0] - 2024-08-19

### Added

* Additional error handling for different format of error response

```
"errors": {
        "inputDto": [
            "The inputDto field is required."
        ],
        "$.claimInformation.serviceLines[0].professionalService.serviceUnitCount": [
            "The JSON value could not be converted to System.String. Path: $.claimInformation.serviceLines[0].professionalService.serviceUnitCount | LineNumber: 0 | BytePositionInLine: 763."
        ]
    }
```

# [5.17.0] - 2024-07-23

### Added

* Additional error handling for different format of error response

```
{
    "error": "invalid_request",
    "error_description": "Invalid request"
}
```

# [5.16.0] - 2024-06-24

### Added

* Ability to accept alternate `endpoint` in submission.

# [5.15.0] - 2024-06-19

### Added

* Ability to accept alternate `base_uri` and `auth_headers` in submission.

# [5.14.0] - 2024-06-11

### Added

* The following report methods can override the base URI, endpoint, and authentication headers per request if needed:
  - `ChangeHealth::Request::Claim::Report.report_list`
  - `ChangeHealth::Request::Claim::Report.get_report`
  - `ChangeHealth::Request::Claim::Report.delete_report`

  Provide the following parameters to override the defaults set in Configuration:
  - `base_uri`
  - `endpoint`
  - `auth_headers` - an empty hash can also be provided (`{}`), which will issue a request to the authentication endpoint instead of using the configured headers.

# [5.13.3] - 2024-05-20

### Fixed

* Grab "id" per claim for ChangeHealth::Response::Claim::Report835Claim INSTEAD of per transaction. B/c each transaction is a payment, not a claim

# [5.13.2] - 2024-05-16

### Fixed

* For ChangeHealth::Response::Claim::Report835Data, the following lists of values will now ignore empty "" in the json, even if the WHOLE field is empty
- claim_payment_remark_codes
- claim_adjustments
- service_adjustments

# [5.13.1] - 2024-05-15

### Fixed

* For ChangeHealth::Response::Claim::Report835Data, the following lists of values will now ignore empty "" in the json
- claim_payment_remark_codes
- claim_adjustments
- service_adjustments

# [5.13.0] - 2024-05-13

### Added

* Grab "id" per transaction for ChangeHealth::Response::Claim::Report835Claim, ChangeHealth::Response::Claim::Report835Payment, and ChangeHealth::Response::Claim::Report277Claim

# [5.12.1] - 2024-05-10

### Fixed

* For ChangeHealth::Response::Claim::ReportData, if multiple json values can be used to find a value, it will now use other json values if the first choice is empty but not nil like `""`

# [5.12.0] - 2024-04-26

### Added

* more_url option to ChangeHealth::Request::Claim::Report

# [5.11.0] - 2024-04-23

### Added

* orderingProvider to ChangeHealth::Models::Claim::ServiceLine

# [5.10.0] - 2024-04-23

### Added

* Support date format YYYY-MM-DD

# [5.9.0] - 2024-04-19

### Added

* Ability to accept headers in submission.

# [5.8.1] - 2024-04-02

### Fixed

ChangeHealth::Response::Error is retryable for retryable codes that do not have a followup action.
Previously, a followup action was required to be retryable.

# [5.8.0] - 2024-03-25

### Added

* Added configurable endpoint overide for claim report

# [5.7.0] - 2024-03-07

### Added

* providers - attending, billing, referring, rendering, and supervising - directly to ChangeHealth::Request::Claim::Submission

# [5.6.0] - 2024-03-06

### Added

* Changed claim submission to use new endpoint override option

# [5.5.0] - 2024-03-06

### Added

* Added new configuration options for endpoint overrides and different authorization
* Now Ruby 3.x compatible
* Changed eligibilty to use new override option

# [5.4.2] - 2023-10-31

### Added

* Added demoProjectIdentifier attribute to ChangeHealth::Models::Claim::ClaimSupplementalInformation

# [5.4.1] - 2023-10-30

### Added

* Moved serviceDate, serviceDateEnd attributes from ChangeHealth::Models::Claim::InstitutionalService to ChangeHealth::Models::Claim::ServiceLine

# [5.4.0] - 2023-10-27

### Added

* Added clearingHouse and serviceName query param to trading_partner query method


# [5.3.1] - 2023-10-25

### Added

* Added clearingHouse query param to trading_partner

# [5.3.0] - 2023-09-18

### Added

* Added new model ChangeHealth::Models::Claim::BillingPayToAddressName
* serviceDate, serviceDateEnd attributes to ChangeHealth::Models::Claim::InstitutionalService
* billingPayToAddressName, tradingPartnerName attributes to ChangeHealth::Request::Claim::Submission

# [5.2.0] - 2023-09-05

### Added

* claimOfficeNumber to ChangeHealth::Models::Claim::Provider

# [5.1.0] - 2023-08-31

### Added

* added alias to trading_partner_data
* added line_of_business to trading_partner_data
* added plan_type to trading_partner_data

# [5.0.0] - 2022-08-24

### Changed

Endpoint for trading_partner request has changed.

* **breaking:** removed medical_eligibility_enabled from trading_partners_data
* **breaking:** removed medical_eligibility_service_id from trading_partner_data
* **breaking:** removed medical_eligibility_service from trading_partner_data
* **breaking:** removed services from trading_partner_data
* updated endpoint on trading_partner
* updated params on trading_partner to only return Eligibility service types
* updated mapping on trading_partner_data for new response from endpoint
* updated tests

# [4.14.0] - 2023-08-24

### Added

* ChangeHealth::Models::Claim::ClaimDateInformation

### Deprecated

* ChangeHealth::Models::DATE_FORMATTER -> ChangeHealth::Models.date_formatter

# [4.13.1] - 2023-08-23

### Fixed

Added institional claim submission specific headers so that institutional claims that required headers will go through in production

# [4.13.0] - 2023-08-11

### Added

#### Ability to submit an institutional claim

* Added the following classes
* ChangeHealth::Models::Claim::ClaimCodeInformation
* ChangeHealth::Models::Claim::InstitutionalService
* Added fields to existing submission classes
* ClaimInformation - claimCodeInformation, claimNote, claimNotes, etc
* ServiceLine - assignedNumber, institutionalService
* ChangeHealth::Request::Claim::Submission#submission now takes `is_professional` argument which defaults to `true`
* `true` for professional claim submission
* `false` for institutional claim submission

#### Added other submission classes

These are used by professional claims and sometimes institutional

* ChangeHealth::Models::Claim::ClaimSupplementalInformation
* ChangeHealth::Models::Claim::ContactInformation
* ChangeHealth::Models::Claim::Diagnosis
* ChangeHealth::Models::Claim::LineAdjudicationInformation
* ChangeHealth::Models::Claim::OtherPayerName
* ChangeHealth::Models::Claim::OtherSubscriberInformation
* ChangeHealth::Models::Claim::OtherSubscriberName
* ChangeHealth::Models::Claim::ProfessionalService
* ChangeHealth::Models::Claim::Receiver
* ChangeHealth::Models::Claim::ReportInformation
* ChangeHealth::Models::Claim::ServiceFacilityLocation

### Deprecated

Some endpoint constants in Submission:

* ChangeHealth::Request::Claim::Submission::ENDPOINT
* ChangeHealth::Request::Claim::Submission::HEALTH_CHECK_ENDPOINT
* ChangeHealth::Request::Claim::Submission::VALIDATION_ENDPOINT
* ChangeHealth::Request::Claim::Submission::SUBMISSION_ENDPOINT

Replace with:

* ENDPOINT -> PROFESSIONAL_ENDPOINT
* HEALTH_CHECK_ENDPOINT -> PROFESSIONAL_ENDPOINT || INSTITUTIONAL_ENDPOINT + HEALTH_CHECK_SUFFIX
* VALIDATION_ENDPOINT -> PROFESSIONAL_ENDPOINT || INSTITUTIONAL_ENDPOINT + SUBMISSION_SUFFIX
* SUBMISSION_ENDPOINT -> PROFESSIONAL_ENDPOINT || INSTITUTIONAL_ENDPOINT + VALIDATION_SUFFIX

# [4.12.0] - 2023-1-23

### Added

* Property `insuranceTypeCode` for ChangeHealth::Models::Claim::Subscriber

# [4.11.0] - 2022-12-30

### Added

* ChangeHealth::Request::Claim::Report - delete a report

# [4.10.1] - 2022-12-29

### Fixed

* Report835ServiceLine - nil exception for create_adjustment_detail_array when there are no service_adjustments

# [4.10.0] - 2022-12-01

### Added

* Request Report - can now pull back any kind of report, not just 277 or 835

# [4.9.0] - 2022-11-11

### Added

* Report835Data - extract `claim_payment_amount` for Report835Claim

# [4.8.0] - 2022-11-09

### Added

* Report835Data - extract `claim_adjustments` for Report835Claim

# [4.7.0] - 2022-09-15

### Added

* Added new attribute to Report835Payment of `payer_address`

# [4.6.0] - 2022-09-01

### Added

* Report835Data - extract claimStatusCode for Report835Claim

# [4.5.0] - 2022-08-29

### Added

* Report835Data - pull out provider adjustments

# [4.4.0] - 2022-08-29

### Added

* Claim Submission - add payToAddress field

# [4.3.0] - 2022-08-08

### Added

* Report835Data - add another way to get service_date_begin & service_date_end

# [4.2.5] - 2022-07-29

### Fixed

* Report835Data can now handle when a service line doesn't have a service date

# [4.2.4] - 2022-07-28

* Removed all RARC Codes (HealthCareCheckRemarkCodes) from JSON

# [4.2.3] - 2022-07-28

* Adjusted `adjustmentAmount` in object returned from create_adjustment_detail_array to a `0` value instead of an empty string

# [4.2.2] - 2022-07-27

* Fixed ChangeHealth::Response::Claim::Report835ServiceLine's `create_adjustment_detail_array` so that if it is `nil` for `health_care_check_remark_codes`, it does not error out

# [4.2.1] - 2022-07-08

### Added

* Added `taxonomyCode` property on `ChangeHealth::Models::Claim` so it will serialize properly into JSON

# [4.2.0] - 2022-06-23

### Added

* Dependent for Claim Submission

# [4.1.0] - 2022-06-17

### Added

Report835Claim - Add another way to get `service_provider_npi`

# [4.0.0] - 2022-05-26

### Changed

The assumption that only one payment would be in a report835 was wrong. Corrected that by adding in a model to hold the payment information - Report835Payment. Removed payment related info from Report835Data and Report835Claim. See README for usage

* check_issue_or_eft_effective_date
* check_or_eft_trace_number
* payer_identifier
* payment_method_code
* report_creation_date
* total_actual_provider_payment_amount

# [3.5.4] - 2022-05-18

* Used dig on `service_provider_npi` variable assigning because it produces way fewer bugs

# [3.5.3] - 2022-05-18

* Added new ways to assign `patient_member_id` and `service_provider_npi` for claim reports returned by insurance

# [3.5.2] - 2022-04-27

* Added properties of `claimNote` to `claimInformation` so it will serialize properly into JSON

# [3.5.1] - 2022-04-12

* Added properties of `lineAdjudicationInformation` and `otherSubscriberInformation` so they can serialize correctly into JSON

# [3.5.0] - 2022-04-08

### Added

* Report835Claim - added payer_identifier property
* Report835ServiceLine - Dynamically creates line_adjustments for remark codes and adjustments that are needed for secondary claims

# [3.4.0] - 2022-03-23

### Added

* Report835Claim - check_or_eft_trace_number & check_issue_or_eft_effective_date

# [3.3.0] - 2022-02-11

### Added

* Report277Claim - 'message' from informationClaimStatuses, clearinghouse_trace_number, patient_account_number, referenced_transaction_trace_number, trading_partner_claim_number
* Report835Claim - patient_control_number
* ReportClaim - report_name, patient_member_id

## [3.2.0] - 2021-12-23

### Added

* Report835HealthCareCheckRemarkCode
* Report835Claim - added claim_payment_remark_codes

## [3.1.0] - 2021-12-21

### Added

#### Claim Submission

* ServiceLine - drugIdentification & renderingProvider
* Subscriber - groupNumber
* Address model w/ postalCode that is formatted to remove dashes, '-'
  * Note: Using a plain hash for address still works
* Auto formatting of postal code fields

## [3.0.0] - 2021-12-08

### Added

* Report277Claim - specific to claims from 277 reports
* Report835Claim - specific to claims from 835 reports
* Report835ServiceAdjustment & Report835ServiceLine - helper classes for readability of claims from 835 reports

### Changed

* ReportClaim - removed 277 report unique fields

#### Namespace

| Previous | Current |
|-|-|
| ChangeHealth::Models::Error | ChangeHealth::Response::Error |
| ChangeHealth::Response::Claim::ReportInfoClaimStatus | ChangeHealth::Response::Claim::Report277InfoClaimStatus|

#### Methods

| Previous | Current |
|-|-|
| Report277Data#payer_org_name | Report277Data#payer_name |
| ReportClaim#latest_total_charge_amount | ReportClaim#total_charge_amount |
| ReportClaim#payer_org_name | ReportClaim#payer_name |
| ReportClaim#service_begin_date | ReportClaim#service_date_begin |
| ReportClaim#service_end_date | ReportClaim#service_date_end |
| ReportClaim#subscriber_first_name | ReportClaim#patient_first_name |
| ReportClaim#subscriber_last_name | ReportClaim#patient_last_name |
| ReportClaim#transaction_set_creation_date | ReportClaim#report_creation_date |

## [2.3.0] - 2021-11-18

### Added

* Report277Data & Report835Data - Specific classes for 277 & 835 reports
* ReportClaim & ReportInfoClaimStatus - only works for json 277 reports

### Fixed

* Headers can now be nil for requests

## [2.2.1] - 2021-11-15

### Added

Custom Headers for Reports API and Professional Claims API

* Report
* Submission

## [2.2.0] - 2021-11-04

### Added

Ability to hit [Claim Responses and Reports](https://developers.changehealthcare.com/eligibilityandclaims/docs/claims-responses-and-reports-getting-started)

* Report
* ReportListData
* ReportData

## [2.1.0] - 2021-10-12

### Changed

Model#to_h enhanced to change empty values AKA "" to nil. Reason: If a field is empty, Change Healthcare responds with an error - `Invalid value. Item must not be blank value.`. If the empty field is optional, Change Healthcare will accept the field as nil without error. If the empty field is required, Change Healthcare will return an error if the value is empty or nil.

## [2.0.0] - 2021-10-08

### Added

#### Models

* ResponseData - for responses from calling change healthcare api used by EligibilityData and SubmissionData

#### Claim Submission

Added the ability to hit professional claim submission API. For more details, see [Change Healthcare documentation here](https://developers.changehealthcare.com/eligibilityandclaims/docs/professional-claims-v3-getting-started)

* ClaimInformation
* Provider
* ServiceLine
* Submission
* SubmissionData
* Submitter
* Subscriber

### Changed

* Using new Change Healthcare url. From apis to apigw. For more info see [change log here](https://developers.changehealthcare.com/eligibilityandclaims/docs/change-logrelease-notes-1)
* PARSE_DATE moved from ChangeHealth::Models::EligibilityData to ChangeHealth::Models
* Moved Error class into its own file

#### Namespace

 Many classes moved namespaces to be more consistent across the many endpoints in Change Healthcare
| Previous | Current |
|-|-|
|ChangeHealth::Models::Eligibility | ChangeHealth::Request::Eligibility |
| ChangeHealth::Models::Encounter | ChangeHealth::Models::Eligibility::Encounter|
| ChangeHealth::Models::Provider | ChangeHealth::Models::Eligibility::Provider|
| ChangeHealth::Models::Subscriber | ChangeHealth::Models::Eligibility::Subscriber|
| ChangeHealth::Models::EligibilityBenefit | ChangeHealth::Response::EligibilityBenefit|
| ChangeHealth::Models::EligibilityBenefits | ChangeHealth::Response::EligibilityBenefits|
| ChangeHealth::Models::EligibilityData | ChangeHealth::Response::EligibilityData|

### Fixed

* Eligibility#add_dependent actually works

## [1.0.3] - 2021-04-26

### Added

* Model::Error#represents_down? - adds ability to distinguish error representing down state

* Model::Error#retryable? - retryable when down
* EligibilityData#recommend_retry? - recommend retry when down

## [1.0.2] - 2021-04-06

### Added

* EligibilityData#recommend_retry? - fix a bug in the search statement

## [1.0.1] - 2021-03-24

### Added

* EligibilityData#plan_status - adds ability to select instead of find

* EligibilityData#inactive? active? - use new plan_status select

## [1.0.0] - 2021-03-17

### Added

* Model::Error - help with error codes

* EligibilityData#recommend_retry? - if it looks like you can retry the exact same request
* EligibilityData#inactive? - looks for plan status 6

## [0.15.0] - 2020-06-12

### Added

* Extensions - InNetworkMissing for plans that don't provide in network indicators.

### Fixed

* Bug where active codes with no service codes cause exception.

## [0.14.0] - 2020-05-07

### Added

* Extensions - mixins for common overrides

## [0.13.0] - 2020-05-05

### Changed

* Removed `alias_method` for `where` helpers so you can override a single method

* Added type Year to Date type 24
* Added type Day type 7

## [0.12.0] - 2020-04-30

### Added

* EligibilityData#errors

* EligibilityData#errors?

## [0.11.0] - 2020-04-24

### Added

* EligibilityData#medicare?

* EligibilityData#plan\_id
* EligibilityData#plan?
* EligibilityBenefits#where\_not
* EligibilityBenefits#+
* EligibilityBenefit#additional\_info
* EligibilityBenefit#descriptions

### Changed

* EligibilityData initialize now checks for sub-classes of EligibilityBenefits with trading partner

* EligibilityData initialize now checks for sub-classes of EligibilityBenefits with trading partner responds to `factory` to choose sub-class
* EligibilityBenefits initializes `self.class` type in case it's a subclass

## [0.10.0] - 2020-04-09

### Added

* Add Trading Partner API querying capability

* Request::TradingPartner
* Response::TradingPartnerData
* Response::TradingPartnersData
* Models::TradingPartner

## [0.9.0] - 2020-04-08

### Added

* Added EligibilityBenefit#medicare?

* Added EligibilityData#medicare?

### Changed

* EligibilityBenefit(s)#individual returns true for medicare in benefit and queries that look for 'IND'

* EligibilityBenefit(s)#in\_network returns true for medicare in benefit and queries that look for 'Y'

## [0.8.0] - 2020-04-04

### Changed

* Attempt to serialize all properties with 'date' in the name to ChangeHealth date format

## [0.7.0] - 2020-04-03

### Changed

* Fixed bug in serializing date on subscriber and encounter

## [0.6.0] - 2020-04-02

### Changed

* Added Indifferent Access to hashes

* Fixed bug with Authentication endpoint

## [0.5.0] - 2020-03-11

### Added

* EligibilityBenefit Deductible information

* EligibilityBenefit benefits date information
* EligibilityBenefit(s) child
* EligibilityBenefit(s) employee
* EligibilityBenefit(s) family
* EligibilityBenefit(s) employee and child

### Changed

* Broke EligibilityBenefit and EligibilityBenefits into separate files

## [0.4.0] - 2020-03-10

### Added

* EligibilityBenefit(s) Employee information

* EligibilityData plan date information
* EligibilityData eligibility, plan and service date helpers on date info

## [0.3.0] - 2020-03-09

### Added

* Production endpoint

## [0.0.2] - 2020-03-09

### Added

* EligibilityData

* EligibilityBenefit
* EligibilityBenefits

### Changed

* Eligibility.query returns EligibilityData object

## [0.0.1] - 2020-03-04

### Added

* Provider

* Subscriber
* Encounter
* Eligibility
* Authentication
* Configuration

[6.1.2]: https://github.com/WeInfuse/change_health/compare/v6.1.1...v6.1.2
[6.1.1]: https://github.com/WeInfuse/change_health/compare/v6.1.0...v6.1.1
[6.1.0]: https://github.com/WeInfuse/change_health/compare/v6.0.0...v6.1.0
[6.0.0]: https://github.com/WeInfuse/change_health/compare/v5.18.0...v6.0.0
[5.18.0]: https://github.com/WeInfuse/change_health/compare/v5.17.0...v5.18.0
[5.17.0]: https://github.com/WeInfuse/change_health/compare/v5.16.0...v5.17.0
[5.16.0]: https://github.com/WeInfuse/change_health/compare/v5.15.0...v5.16.0
[5.15.0]: https://github.com/WeInfuse/change_health/compare/v5.14.0...v5.15.0
[5.14.0]: https://github.com/WeInfuse/change_health/compare/v5.13.3...v5.14.0
[5.13.3]: https://github.com/WeInfuse/change_health/compare/v5.13.2...v5.13.3
[5.13.2]: https://github.com/WeInfuse/change_health/compare/v5.13.1...v5.13.2
[5.13.1]: https://github.com/WeInfuse/change_health/compare/v5.13.0...v5.13.1
[5.13.0]: https://github.com/WeInfuse/change_health/compare/v5.12.1...v5.13.0
[5.12.1]: https://github.com/WeInfuse/change_health/compare/v5.12.0...v5.12.1
[5.12.0]: https://github.com/WeInfuse/change_health/compare/v5.11.0...v5.12.0
[5.11.0]: https://github.com/WeInfuse/change_health/compare/v5.10.0...v5.11.0
[5.10.0]: https://github.com/WeInfuse/change_health/compare/v5.9.0...v5.10.0
[5.9.0]: https://github.com/WeInfuse/change_health/compare/v5.8.1...v5.9.0
[5.8.1]: https://github.com/WeInfuse/change_health/compare/v5.8.0...v5.8.1
[5.8.0]: https://github.com/WeInfuse/change_health/compare/v5.7.0...v5.8.0
[5.7.0]: https://github.com/WeInfuse/change_health/compare/v5.6.0...v5.7.0
[5.6.0]: https://github.com/WeInfuse/change_health/compare/v5.5.0...v5.6.0
[5.5.0]: https://github.com/WeInfuse/change_health/compare/v5.4.2...v5.5.0
[5.4.2]: https://github.com/WeInfuse/change_health/compare/v5.4.1...v5.4.2
[5.4.1]: https://github.com/WeInfuse/change_health/compare/v5.4.0...v5.4.1
[5.4.0]: https://github.com/WeInfuse/change_health/compare/v5.3.1...v5.4.0
[5.3.1]: https://github.com/WeInfuse/change_health/compare/v5.3.0...v5.3.1
[5.3.0]: https://github.com/WeInfuse/change_health/compare/v5.2.0...v5.3.0
[5.2.0]: https://github.com/WeInfuse/change_health/compare/v5.1.0...v5.2.0
[5.1.0]: https://github.com/WeInfuse/change_health/compare/v5.0.0...v5.1.0
[5.0.0]: https://github.com/WeInfuse/change_health/compare/v4.14.0...v5.0.0
[4.14.0]: https://github.com/WeInfuse/change_health/compare/v4.13.1...v4.14.0
[4.13.1]: https://github.com/WeInfuse/change_health/compare/v4.13.0...v4.13.1
[4.13.0]: https://github.com/WeInfuse/change_health/compare/v4.12.0...v4.13.0
[4.12.0]: https://github.com/WeInfuse/change_health/compare/v4.11.0...v4.12.0
[4.11.0]: https://github.com/WeInfuse/change_health/compare/v4.10.1...v4.11.0
[4.10.1]: https://github.com/WeInfuse/change_health/compare/v4.10.0...v4.10.1
[4.10.0]: https://github.com/WeInfuse/change_health/compare/v4.9.0...v4.10.0
[4.9.0]: https://github.com/WeInfuse/change_health/compare/v4.8.0...v4.9.0
[4.8.0]: https://github.com/WeInfuse/change_health/compare/v4.7.0...v4.8.0
[4.7.0]: https://github.com/WeInfuse/change_health/compare/v4.6.0...v4.7.0
[4.6.0]: https://github.com/WeInfuse/change_health/compare/v4.5.0...v4.6.0
[4.5.0]: https://github.com/WeInfuse/change_health/compare/v4.4.0...v4.5.0
[4.4.0]: https://github.com/WeInfuse/change_health/compare/v4.3.0...v4.4.0
[4.3.0]: https://github.com/WeInfuse/change_health/compare/v4.2.5...v4.3.0
[4.2.5]: https://github.com/WeInfuse/change_health/compare/v4.2.4...v4.2.5
[4.2.4]: https://github.com/WeInfuse/change_health/compare/v4.2.3...v4.2.4
[4.2.3]: https://github.com/WeInfuse/change_health/compare/v4.2.2...v4.2.3
[4.2.2]: https://github.com/WeInfuse/change_health/compare/v4.2.1...v4.2.2
[4.2.1]: https://github.com/WeInfuse/change_health/compare/v4.2.0...v4.2.1
[4.2.0]: https://github.com/WeInfuse/change_health/compare/v4.1.0...v4.2.0
[4.1.0]: https://github.com/WeInfuse/change_health/compare/v4.0.0...v4.1.0
[4.0.0]: https://github.com/WeInfuse/change_health/compare/v3.5.4...v4.0.0
[3.5.4]: https://github.com/WeInfuse/change_health/compare/v3.5.3...v3.5.4
[3.5.3]: https://github.com/WeInfuse/change_health/compare/v3.5.2...v3.5.3
[3.5.2]: https://github.com/WeInfuse/change_health/compare/v3.5.1...v3.5.2
[3.5.1]: https://github.com/WeInfuse/change_health/compare/v3.5.0...v3.5.1
[3.5.0]: https://github.com/WeInfuse/change_health/compare/v3.4.0...v3.5.0
[3.4.0]: https://github.com/WeInfuse/change_health/compare/v3.3.0...v3.4.0
[3.3.0]: https://github.com/WeInfuse/change_health/compare/v3.2.0...v3.3.0
[3.2.0]: https://github.com/WeInfuse/change_health/compare/v3.1.0...v3.2.0
[3.1.0]: https://github.com/WeInfuse/change_health/compare/v3.0.0...v3.1.0
[3.0.0]: https://github.com/WeInfuse/change_health/compare/v2.3.0...v3.0.0
[2.3.0]: https://github.com/WeInfuse/change_health/compare/v2.2.1...v2.3.0
[2.2.1]: https://github.com/WeInfuse/change_health/compare/v2.2.0...v2.2.1
[2.2.0]: https://github.com/WeInfuse/change_health/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/WeInfuse/change_health/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/WeInfuse/change_health/compare/v1.0.3...v2.0.0
[1.0.3]: https://github.com/WeInfuse/change_health/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/WeInfuse/change_health/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/WeInfuse/change_health/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/WeInfuse/change_health/compare/v0.15.0...v1.0.0
[0.15.0]: https://github.com/WeInfuse/change_health/compare/v0.14.0...v0.15.0
[0.14.0]: https://github.com/WeInfuse/change_health/compare/v0.13.0...v0.14.0
[0.13.0]: https://github.com/WeInfuse/change_health/compare/v0.12.0...v0.13.0
[0.12.0]: https://github.com/WeInfuse/change_health/compare/v0.11.0...v0.12.0
[0.11.0]: https://github.com/WeInfuse/change_health/compare/v0.10.0...v0.11.0
[0.10.0]: https://github.com/WeInfuse/change_health/compare/v0.9.0...v0.10.0
[0.9.0]: https://github.com/WeInfuse/change_health/compare/v0.8.0...v0.9.0
[0.8.0]: https://github.com/WeInfuse/change_health/compare/v0.7.0...v0.8.0
[0.7.0]: https://github.com/WeInfuse/change_health/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/WeInfuse/change_health/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/WeInfuse/change_health/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/WeInfuse/change_health/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/WeInfuse/change_health/compare/v0.0.2...v0.3.0
[0.0.2]: https://github.com/WeInfuse/change_health/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/WeInfuse/change_health/compare/520a8c54d07...v0.0.1
