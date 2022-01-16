# cg-egress-proxy

## Why this project

Compromised applications are often used to exfiltrate data, participate in [DoS](https://www.cisa.gov/uscert/ncas/tips/ST04-015) attacks, directly exploit other services, or phone home for additional nefarious commands. When you block unexpected egress traffic from your system, you mitigate the potential damage that would result from a compromised app, and help keep other systems secure.

The app in this repository implements controlled egress traffic for applications running on [cloud.gov](https://cloud.gov), and should work on other [Cloud Foundry](https://cloudfoundry.org)-based platforms as well.

<details>
<summary>Want to know about NIST 800-53 SC-7? Click here...</summary>

### Hello Compliance and security nerds! 

Creators of of US federal systems are [required](https://csrc.nist.gov/projects/risk-management/fisma-background) to implement baseline [security and privacy controls](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final) appropriate to the system's [sensitivity](https://www.nist.gov/privacy-framework/fips-199). [Control SC-7](https://csrc.nist.gov/Projects/risk-management/sp800-53-controls/release-search#!/control?version=5.1&number=sc-7) includes this text:

> Connect to external networks or systems only through managed interfaces consisting of boundary protection devices arranged in accordance with an organizational security and privacy architecture.

Deploying this egress proxy in front of your cloud.gov application will help you meet this requirement!

<!-- assortedkeywords: nist rmf 800-53 fisma fedramp sc-7 gsa boundary egress -->
</details>

---

## Deployment

Deploy the proxy in a public_egress space. (Optionally deploy it in another org altogether.)

    cf t -s prod-egress [-o otherorg]
    cf push yourorg-proxy -d apps.internal []...]

Enable your client to connect to the proxy

    PORT=61443
    cf t -s prod [-o yourorg]
    cf add-network-policy app yourorg-proxy --port $PORT -s prod-egress [-o otherorg]

Tell your app about the proxy. (You can also set these env vars in your `.profile`.)

    cf set-env http_proxy  'https://yourorg-proxy.app.internal:61443'
    cf set-env https_proxy 'https://yourorg-proxy.app.internal:61443'

Test that the proxy configuration is correct, from the app perspective.

    # Get a shell inside the app
    cf ssh app
    /tmp/lifecycle/shell

    # Test that we can reach things we should
    curl http://allowedhost:allowedport     # connects
    curl https://allowedhost:allowedport    # connects
    
    # Test that we can't reach things we shouldn't
    curl http://allowedhost:deniedport      # connection refused
    curl http://deniedhost:allowedport      # connection refused
    curl https://allowedhost:deniedport     # connection refused
    curl https://deniedhost:allowedport     # connection refused

If necessary, configure your app content to use the value in the `http_proxy` and `https_proxy` environment variables as the proxy setting when making egress connections.

## How it works

- The proxy runs [Caddy V2](https://caddyserver.com)
  - Caddy is compiled to include the [forwardproxy](https://github.com/caddyserver/forwardproxy/tree/caddy2) plugin
  - _TODO:_ Caddy's forwardproxy configuration gets the allowed hosts and ports from environment variables provided at startup.
- Caddy listens on one port: $PORT
  - It does no TLS termination on this port
  - It always sees plaintext for the _inital_ client connection, until it receives CONNECT
  - After that, according to the spec:
    - It CAN   see the content of requests to http://  destinations
    - It CAN'T see the content of requests to https:// destinations
      - The TLS exchange between the client and destination happens post-CONNECT over a TCP tunnel
- Cloud Foundry makes the proxy available to other containers *without* TLS on $PORT
- Cloud Foundry makes the proxy available to othe containers *with*    TLS on 61443

Use the correct port for traffic to the proxy on cloud.gov! (The destination protocol/port _does not matter_, only the port to the proxy.)

- Use yourorg-proxy.app.internal:61443 (with TLS)    - CF operators see TLS
  - Do this unless you have a reason not to. Also: There is no good reason not to.
- Use yourorg-proxy.app.internal:$PORT (without TLS) - CF operators see cleartext
  - aka "I want the CF operators and other possibly compromised containers to be able to sniff the content of traffic between my client and the proxy"
  - Don't do this.

## For development

## Local testing

1. Run `docker-compose up --build`.
2. Set the environment variable `http_proxy=http://localhost:8080`
    - CF isn't handling TLS termination locally
    - This means you normally only test using cleartext to the proxy.
3. Test allowed and denied destinations and ports:

    ```
    curl https://allowedhost:allowedport    # (connects)           PASS
    curl https://allowedhost:deniedport     # (connection refused) PASS
    curl https://deniedhost:allowedport     # (connection refused) PASS
    ```

_TODO: Add a test that does exactly this._

### If you must develop with TLS...

To support local development (where CF isn't around to terminate TLS)

- Caddy also listens on 443 WITH TLS, using certificates signed with its own root CA
    - You WILL see cert errors if you set `https_proxy=https://localhost:443`
- To stop seeing cert errors, add Caddy's internal root CA certificate to your client.
  - The root CA certificate is in the Caddy container at `/data/caddy/pki/authorities/local/root.crt`
  - How to add the root CA certificate depends on the client (TODO: Finish researching and add all the links):
    - windows (system wide):
    - linux (system wide):
    - mac (system wide):
    - Firefox:
    - Chrome:
    - IE9+:
    - curl: Set flag `--proxy-cacert filename`
    - go:
    - python:
    - ruby:
    - php:
    - java:

_Note:_ If you happen to connect to proxy.app.internal:443 on cloud.gov, _you will see these same cert errors_. You could go retrieve that root CA certificate from the same path in the proxy app with `cf ssh` but _why would you want to?! Don't do that. Just use port 61443.)

We may be able to [eliminate the hurdles of testing with TLS locally](https://github.com/caddyserver/caddy/issues/3021) in the future.

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md) for additional information.

## Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
