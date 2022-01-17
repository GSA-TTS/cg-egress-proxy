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

<!-- assorted keywords: nist rmf 800-53 fisma fedramp sc-7 gsa boundary egress -->
</details>

---

## Deploying the proxy by hand

Build the caddy binary

    $ make

Copy and edit the vars.yml-sample settings file. (Convention is to name it after your app.)

    $ cp vars.yml-sample vars.myapp.yml
    $ $EDITOR vars.myapp.yml

The values for proxydeny and proxyallow should consist of the relevant entries for your app, separated by spaces or newlines. Entries can be hostnames, IPs, or ranges for both, and can be expressed in many different forms. For examples, see [the upstream documentation](https://github.com/caddyserver/forwardproxy/blob/caddy2/README.md#caddyfile-syntax-server-configuration). 

Deploy the proxy in a neighboring space with public egress. (Or optionally deploy it in another org altogether.)

    $ cf t -s prod-egress [-o otherorg]
    $ cf push --vars-file vars.myapp.yml

Enable your client to connect to the proxy.

    cf t -s prod [-o yourorg]
    cf add-network-policy app myproxy --port $PORT -s prod-egress [-o otherorg]

Help your app find the the proxy.

    $ cf set-env http_proxy  'https://user:pass@myproxy.app.internal:8080'
    $ cf set-env https_proxy 'https://user:pass@myproxy.app.internal:8080'

Note that setting the environment variables this way is only for convenience. You may see credentials appear in log or `cf env` output, for example.

It's better if you use one of these other options: 
1. Use a [user-provied service]() to provide the URLs to your app.
2. Use the [`.profile`](https://docs.cloudfoundry.org/devguide/deploy-apps/deploy-app.html#profile) to set these variables during your app's initialization.

    #!/bin/bash
    export http_proxy="https://user:pass@myproxy.app.internal:8080"
    export https_proxy="https://user:pass@myproxy.app.internal:8080"

## Deploying proxies for a bunch of apps automatically

The `bin/cf-deployproxy` utility sets up proxies for many apps at once, following some simple conventions. You can specify deny and allow lists tailored for each application. The utility will also ensure that apps can reach any S3 bucket services that are bound to them.

To set up tailored lists for each app, the utility reads a file called `<app>.deny.acl` for denied entries, and a file called `<app>.allow.acl` for allowed entries. The tool will create these files if they don't exist, and is safe to run multiple times. If you have a lot of apps to set up, just run it and then edit the files that are created.

To learn more about how to use this tool, just run it!

    $ bin/cf-deployproxy -h

## Troubleshooting

Test that curl connects properly from your application's container.

    # Get a shell inside the app
    $ cf ssh app -t -c "/tmp/lifecycle/launcher /home/vcap/app /bin/bash"

    # Use curl to test that the container can reach things it should
    $ curl http://allowedhost:allowedport     # connects
    [...]
    $ curl https://allowedhost:allowedport    # connects
    [...]
    
    # Use curl to test that the container can't reach things it shouldn't
    $ curl http://allowedhost:deniedport      # connection refused
    curl: (56) Received HTTP code 403 from proxy after CONNECT
    $ curl http://deniedhost:allowedport      # connection refused
    curl: (56) Received HTTP code 403 from proxy after CONNECT
    $ curl https://allowedhost:deniedport     # connection refused
    curl: (56) Received HTTP code 403 from proxy after CONNECT
    $ curl https://deniedhost:allowedport     # connection refused
    curl: (56) Received HTTP code 403 from proxy after CONNECT

If that all looks OK: Remember, your app must implicitly or explicitly make use of use the `http_proxy` and `https_proxy` environment variables values when making connections to an allowedhost. Are you sure it's doing that?

If not, then it's time to see if it's working from the proxy itself. Test that it works by SSH'ing and allowing the .profile to load.

    $ cf ssh myapp -t -c "/tmp/lifecycle/shell /home/vcap/app /bin/bash"
        $ curl https://notallowedhost
        curl: (56) Received HTTP code 403 from proxy after CONNECT  # <-- This is good!
        $ curl https://allowedhost
        [...normal allowedhost response...]

        # If something doesn't seem to be working right, add the -I and -v flags
        $ curl -I -v https://deniedhost
        [...pretty straightforward rejection from the proxy right after CONNECT...]
        $ curl -I -v https://allowedhost
        [...more information than you require...
        
        exit

If that _doesn't_ look OK: You may be using the proxy in a new or unexpected way, or you may have found a bug. Please file an issue or otherwise contact the project's maintainers!

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
