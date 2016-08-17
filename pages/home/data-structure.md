---
title: Data Structure
keywords: overview
sidebar: home_sidebar
permalink: /data-structure
toc: true
---

##  Violation Records

Each record in the code violations dataset represents an incident (a "violation") in which the conditions for a particular piece of property violate some ordinance. Because the conditions for the property may violate more than one ordinance, there can be multiple violations recorded for the property. When that happens, the violation records are all linked together into a "case" to present a more holistic picture of what is happening with the property. So, for instance, it is quite common to see the same "case id" on multiple records. It is good to keep in mind that certain data elements on each record are, so to speak, on the "case level" (that is, they are the same across all records for the case).

## Case Level

Rather than simply list all the fields in a record, it may be more useful to group those fields logically. The case level fields identify the case and tell us when it started and ended.

| Field | Description |
|-------|-------------|
| Case ID | The identifier of the case |
| Status | Whether the case is open or closed. It's important that it is possible the individual violation may have been resolved even if the status is open, because the status is at the case level. |
| Case Opened Date | The date on which the case was opened (typically, the date of the first violation). Again, this may not be the same as the date the violation was discovered. |
| Case Closed Date | For closed cases, the date of closure. |

## Location

Location fields tell us about where the violation occurred. Some location fields identify the address specifics, while others simply identify an area that the violation is within. There are some situations in which an address is so general (e.g., for some mobile home parks) that the address does not actually isolate the particular property in violation.

| Field | Description |
|-------|-------------|
| Address | The street address. |
| County | The county in which the address is located. Kansas City spans four different counties. |
| State | Always Missouri. |
| Zip Code | The zip code. |
| KIVA PIN | A (mostly) unique identifier ascribed to addresses by Kansas City's internal systems. Can be used to look up properties at [KivaWeb](http://kivaweb.kcmo.org/kivanet/2/index.cfm). Ideally, the KIVA Pin will differ in those cases where distinct properties share a common street address. |
| Council District | The City Council district number. |
| Police Patrol Area | The police patrol area in which the violation is located. |
| Inspection Area | The city is divided up into different areas for inspection coverage purposes, and this identifies the inspection area in which the violation occurred. |
| Neighborhood | The city has defined neighborhoods, and this names the neighborhood in which the violation occurred. |
| Code Violation Location | This is an aggregate field that contains a complete address, as well as (for the most part) a latitude and longitude. This field makes it easier to map the violations. |

## Violation Information

Finally, there are the fields that can be considered the meat of the record, those that provide information on a specific violation.

| Field | Description |
|-------|-------------|
| Property Violation ID | A unique identifier for a specific violation. |
| Days Open | The number of days a violation has been or was open. Note that this field is inferred as part of the system process that produces the open data and is not necessarily consistent with the case level open and closed dates. |
| Ordinance Chapter | The chapter of the municipal code containing the ordinance that has been violated. The two most common chapters are 48 (nuisance) and property maintenance (56). |
| Ordinance Number | The ordinance that has been violated. |
| Ordinance Code | An internal code that helps identify the violation more specifically than the ordinance number. |
| Ordinance Description | A text description of the violation. |
| Violation Entry Date | The date the violation was logged into the case. |
