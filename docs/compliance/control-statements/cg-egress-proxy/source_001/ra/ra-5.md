---
x-trestle-comp-def-rules:
  cg-egress-proxy:
    - name: cg-egress-proxy-implemented
      description: This control is fully implemented for the scope of the CG Egress
        Proxy component
x-trestle-param-values:
  ra-5_prm_1:
  ra-05_odp.01:
  ra-05_odp.02:
  ra-05_odp.03:
  ra-05_odp.04:
x-trestle-global:
  profile:
    title: Electronic Version of NIST SP 800-53 Rev 5.1.1 Controls and SP 800-53A
      Rev 5.1.1 Assessment Procedures
    href: 
      https://raw.githubusercontent.com/usnistgov/oscal-content/refs/tags/v1.3.0/nist.gov/SP800-53/rev5/json/NIST_SP-800-53_rev5_catalog.json
  sort-id: ra-05
---

# ra-5 - \[Risk Assessment\] Vulnerability Monitoring and Scanning

## Control Statement

- \[a.\] Monitor and scan for vulnerabilities in the system and hosted applications {{ insert: param, ra-5_prm_1 }} and when new vulnerabilities potentially affecting the system are identified and reported;

- \[b.\] Employ vulnerability monitoring tools and techniques that facilitate interoperability among tools and automate parts of the vulnerability management process by using standards for:

  - \[1.\] Enumerating platforms, software flaws, and improper configurations;
  - \[2.\] Formatting checklists and test procedures; and
  - \[3.\] Measuring vulnerability impact;

- \[c.\] Analyze vulnerability scan reports and results from vulnerability monitoring;

- \[d.\] Remediate legitimate vulnerabilities {{ insert: param, ra-05_odp.03 }} in accordance with an organizational assessment of risk;

- \[e.\] Share information obtained from the vulnerability monitoring process and control assessments with {{ insert: param, ra-05_odp.04 }} to help eliminate similar vulnerabilities in other systems; and

- \[f.\] Employ vulnerability monitoring tools that include the capability to readily update the vulnerabilities to be scanned.

## Control Assessment Objective

- \[RA-05a.\]

  - \[RA-05a.[01]\] systems and hosted applications are monitored for vulnerabilities {{ insert: param, ra-05_odp.01 }} and when new vulnerabilities potentially affecting the system are identified and reported;
  - \[RA-05a.[02]\] systems and hosted applications are scanned for vulnerabilities {{ insert: param, ra-05_odp.02 }} and when new vulnerabilities potentially affecting the system are identified and reported;

- \[RA-05b.\] vulnerability monitoring tools and techniques are employed to facilitate interoperability among tools;

  - \[RA-05b.01\] vulnerability monitoring tools and techniques are employed to automate parts of the vulnerability management process by using standards for enumerating platforms, software flaws, and improper configurations;
  - \[RA-05b.02\] vulnerability monitoring tools and techniques are employed to facilitate interoperability among tools and to automate parts of the vulnerability management process by using standards for formatting checklists and test procedures;
  - \[RA-05b.03\] vulnerability monitoring tools and techniques are employed to facilitate interoperability among tools and to automate parts of the vulnerability management process by using standards for measuring vulnerability impact;

- \[RA-05c.\] vulnerability scan reports and results from vulnerability monitoring are analyzed;

- \[RA-05d.\] legitimate vulnerabilities are remediated {{ insert: param, ra-05_odp.03 }} in accordance with an organizational assessment of risk;

- \[RA-05e.\] information obtained from the vulnerability monitoring process and control assessments is shared with {{ insert: param, ra-05_odp.04 }} to help eliminate similar vulnerabilities in other systems;

- \[RA-05f.\] vulnerability monitoring tools that include the capability to readily update the vulnerabilities to be scanned are employed.

## Control guidance

Security categorization of information and systems guides the frequency and comprehensiveness of vulnerability monitoring (including scans). Organizations determine the required vulnerability monitoring for system components, ensuring that the potential sources of vulnerabilities—such as infrastructure components (e.g., switches, routers, guards, sensors), networked printers, scanners, and copiers—are not overlooked. The capability to readily update vulnerability monitoring tools as new vulnerabilities are discovered and announced and as new scanning methods are developed helps to ensure that new vulnerabilities are not missed by employed vulnerability monitoring tools. The vulnerability monitoring tool update process helps to ensure that potential vulnerabilities in the system are identified and addressed as quickly as possible. Vulnerability monitoring and analyses for custom software may require additional approaches, such as static analysis, dynamic analysis, binary analysis, or a hybrid of the three approaches. Organizations can use these analysis approaches in source code reviews and in a variety of tools, including web-based application scanners, static analysis tools, and binary analyzers.

Vulnerability monitoring includes scanning for patch levels; scanning for functions, ports, protocols, and services that should not be accessible to users or devices; and scanning for flow control mechanisms that are improperly configured or operating incorrectly. Vulnerability monitoring may also include continuous vulnerability monitoring tools that use instrumentation to continuously analyze components. Instrumentation-based tools may improve accuracy and may be run throughout an organization without scanning. Vulnerability monitoring tools that facilitate interoperability include tools that are Security Content Automated Protocol (SCAP)-validated. Thus, organizations consider using scanning tools that express vulnerabilities in the Common Vulnerabilities and Exposures (CVE) naming convention and that employ the Open Vulnerability Assessment Language (OVAL) to determine the presence of vulnerabilities. Sources for vulnerability information include the Common Weakness Enumeration (CWE) listing and the National Vulnerability Database (NVD). Control assessments, such as red team exercises, provide additional sources of potential vulnerabilities for which to scan. Organizations also consider using scanning tools that express vulnerability impact by the Common Vulnerability Scoring System (CVSS).

Vulnerability monitoring includes a channel and process for receiving reports of security vulnerabilities from the public at-large. Vulnerability disclosure programs can be as simple as publishing a monitored email address or web form that can receive reports, including notification authorizing good-faith research and disclosure of security vulnerabilities. Organizations generally expect that such research is happening with or without their authorization and can use public vulnerability disclosure channels to increase the likelihood that discovered vulnerabilities are reported directly to the organization for remediation.

Organizations may also employ the use of financial incentives (also known as "bug bounties" ) to further encourage external security researchers to report discovered vulnerabilities. Bug bounty programs can be tailored to the organization’s needs. Bounties can be operated indefinitely or over a defined period of time and can be offered to the general public or to a curated group. Organizations may run public and private bounties simultaneously and could choose to offer partially credentialed access to certain participants in order to evaluate security vulnerabilities from privileged vantage points.

______________________________________________________________________

## What is the solution and how is it implemented?

<!-- For implementation status enter one of: implemented, partial, planned, alternative, not-applicable -->

<!-- Note that the list of rules under ### Rules: is read-only and changes will not be captured after assembly to JSON -->

<!-- Add control implementation description here for control: ra-5 -->

### Implementation Status: partial

______________________________________________________________________

## Implementation for part a.

CG Egress Proxy is scanned via the [govulncheck](https://pkg.go.dev/golang.org/x/vuln/cmd/govulncheck) utility at the following times:

* Every time a new PR is created to update the proxy
* Every time the `main` branch is pushed to
* Daily overnight to ensure new vulnerabilities are found even when changes are not made.

### Rules:

  - cg-egress-proxy-implemented

### Implementation Status: implemented

______________________________________________________________________

## Implementation for part f.

The latest govulncheck library is installed freshly each time the scan is run, thereby updating its knowledge of the most recent vulnerabilities.

### Rules:

  - cg-egress-proxy-implemented

### Implementation Status: implemented

______________________________________________________________________
