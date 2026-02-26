# Security Baseline Implementation

**These rules implement the [2025.10.10][baseline-2025] OSPS Security Baseline**

[OpenSSF Security Baseline][baseline] describes a set of security best practices to help open source projects establish and maintain a consistent security posture. The guidance in the Baseline is derived from multiple existing cybersecurity standards and tailored to address open source projects. Controls and specific requirements are coded based on project maturity: level 1 assessments are designed to apply to projects of all sizes, while level 3 guidance aims to apply to large, multi-stakeholder software efforts. The baseline provides actionable guidance on critical security practices such as access control, code review processes, vulnerability disclosure, testing, documentation, and build process.

The Custcodian team actively participates in the OpenSSF Security Baseline process and maintains a collection of minder rules and profiles which implement the Baseline security assessment (currently, level 1) at https://github.com/custcodian/minder-rules-and-profiles

These rules are designed to automatically measure and improve compliance with the OpenSSF Security Baseline (OSPS). The Custcodian team regularly contributes improvements upstream to the [OpenSSF Minder rules repository][upstream-rules]; you can use either repository depending on your needs -- the Custcodian repository will receive updates first, while the Minder repository will only receive full, stable updates.

## Syncing and Applying OSPS Baseline Rules
To sync and apply the OSPS Baseline rules to your GitHub repositories through the Custcodian hosted Minder instance:

1. Clone the minder rules repository:

   ```bash
   git clone https://github.com/custcodian/minder-rules-and-profiles.git
   ```

1. [Install](https://docs.mindersec.dev/getting_started/install_cli) and [configure](https://docs.mindersec.dev/getting_started/login) the minder CLI tool.

1. [Install Minder on your GitHub organization, and associate it with your Minder project](https://docs.mindersec.dev/getting_started/enroll_provider).

1. [Register specific repositories](https://docs.mindersec.dev/getting_started/register_repos) you want to assess.

1. From the `minder-rules-and-profiles` repository, apply the Baseline profile and rules using Minder:

   ```bash
   minder apply -f security-baseline
   ```

## Additional information

For more information on the OpenSSF Security Baseline, visit: https://baseline.openssf.org/

For more information on OpenSSF Minder, visit: https://mindersec.dev/

[baseline-2025]: https://baseline.openssf.org/versions/2025-10-10
[baseline]: https://baseline.openssf.org/
[upstream-rules]: https://github.com/mindersec/minder-rules-and-profiles/ 