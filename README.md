# cg-egress-proxy

## Why this project

### For normal people

Compromised applications will often be used to exfiltrate data, participate in [DoS](https://www.cisa.gov/uscert/ncas/tips/ST04-015) attacks, or directly exploit other services, or phone home for additional nefarious commands. When you  block unexpected egress traffic from your system, you mitigate the potential damage that would result from a compromised app, and help keep other systems secure.

The app in this repository implements controlled egress traffic for applications running on [cloud.gov](https://cloud.gov), and should work with other [Cloud Foundry](https://cloudfoundry.org)platforms as well.

### For compliance and security nerds

_Note_: Creators of of US federal systems are [required](https://csrc.nist.gov/projects/risk-management/fisma-background) to implement baseline [security and privacy controls](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final) appropriate to the system's [sensitivity](https://www.nist.gov/privacy-framework/fips-199). [Control SC-7](https://csrc.nist.gov/Projects/risk-management/sp800-53-controls/release-search#!/control?version=5.1&number=sc-7) includes this text:

> Connect to external networks or systems only through managed interfaces consisting of boundary protection devices arranged in accordance with an organizational security and privacy architecture.

Deploying this egress proxy in front of your cloud.gov application will help you meet this requirement.

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md) for additional information.

## Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
