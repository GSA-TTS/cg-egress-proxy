---
x-trestle-comp-def-rules:
  cg-egress-proxy:
    - name: prod-space-restricted
      description: The production space where the system app is running must not have
        the public-networks-egress ASG applied to it
x-trestle-param-values:
  sc-07_odp:
x-trestle-global:
  profile:
    title: Electronic Version of NIST SP 800-53 Rev 5.1.1 Controls and SP 800-53A
      Rev 5.1.1 Assessment Procedures
    href: trestle://catalogs/nist800-53r5/catalog.json
  sort-id: sc-07
---

# sc-7 - \[System and Communications Protection\] Boundary Protection

## Control Statement

- \[a.\] Monitor and control communications at the external managed interfaces to the system and at key internal managed interfaces within the system;

- \[b.\] Implement subnetworks for publicly accessible system components that are {{ insert: param, sc-07_odp }} separated from internal organizational networks; and

- \[c.\] Connect to external networks or systems only through managed interfaces consisting of boundary protection devices arranged in accordance with an organizational security and privacy architecture.

## Control Assessment Objective

- \[SC-07a.\]

  - \[SC-07a.[01]\] communications at external managed interfaces to the system are monitored;
  - \[SC-07a.[02]\] communications at external managed interfaces to the system are controlled;
  - \[SC-07a.[03]\] communications at key internal managed interfaces within the system are monitored;
  - \[SC-07a.[04]\] communications at key internal managed interfaces within the system are controlled;

- \[SC-07b.\] subnetworks for publicly accessible system components are {{ insert: param, sc-07_odp }} separated from internal organizational networks;

- \[SC-07c.\] external networks or systems are only connected to through managed interfaces consisting of boundary protection devices arranged in accordance with an organizational security and privacy architecture.

## Control guidance

Managed interfaces include gateways, routers, firewalls, guards, network-based malicious code analysis, virtualization systems, or encrypted tunnels implemented within a security architecture. Subnetworks that are physically or logically separated from internal networks are referred to as demilitarized zones or DMZs. Restricting or prohibiting interfaces within organizational systems includes restricting external web traffic to designated web servers within managed interfaces, prohibiting external traffic that appears to be spoofing internal addresses, and prohibiting internal traffic that appears to be spoofing external addresses. [SP 800-189](#f5edfe51-d1f2-422e-9b27-5d0e90b49c72) provides additional information on source address validation techniques to prevent ingress and egress of traffic with spoofed addresses. Commercial telecommunications services are provided by network components and consolidated management systems shared by customers. These services may also include third party-provided access lines and other service elements. Such services may represent sources of increased risk despite contract security provisions. Boundary protection may be implemented as a common control for all or part of an organizational network such that the boundary to be protected is greater than a system-specific boundary (i.e., an authorization boundary).

______________________________________________________________________

## What is the solution and how is it implemented?

<!-- For implementation status enter one of: implemented, partial, planned, alternative, not-applicable -->

<!-- Note that the list of rules under ### Rules: is read-only and changes will not be captured after assembly to JSON -->

<!-- Add control implementation description here for control: sc-7 -->

### Implementation Status: partial

______________________________________________________________________

## Implementation for part c.

eg-egress-proxy provides a control point for allowing network traffic to specific hostnames or IP addresses. Outbound connections are compared to the following list in order:

1. A `deny_file` list of hostnames and/or IP addresses to deny connections to.
1. An `allow_file` list of hostnames and/or IP addresses to allow connections to.
1. A `deny all` rule to deny all connections that did not match one of the first two rules.

The connection is allowed or denied based on the first matching rule.

### Rules:

  - prod-space-restricted

### Implementation Status: implemented

______________________________________________________________________
