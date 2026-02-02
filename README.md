# cg-egress-proxy

## Why this project

Compromised applications are often used to exfiltrate data, participate in [DoS](https://www.cisa.gov/uscert/ncas/tips/ST04-015) attacks, directly exploit other services, or phone home for additional nefarious commands. When you block unexpected egress traffic from your system, you mitigate the potential damage that would result from a compromised app, and help keep other systems secure.

The app in this repository implements controlled egress traffic for applications running on [cloud.gov](https://cloud.gov), and should work on other [Cloud Foundry](https://cloudfoundry.org)-based platforms as well.

**Note:**
>This project is not currently officially supported by the cloud.gov team due to the diveristy of use-cases and complexity of configurations possible. The cloud.gov support team cannot guarantee that they can assist in debugging the use of this proxy, and can only assist in the use of this proxy to users under an official support package with cloud.gov.

<details>
<summary>Want to know about NIST 800-53 SC-7? Click here...</summary>

### Hello Compliance and security nerds!

Creators of of US federal systems are [required](https://csrc.nist.gov/projects/risk-management/fisma-background) to implement baseline [security and privacy controls](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final) appropriate to the system's [sensitivity](https://www.nist.gov/privacy-framework/fips-199). [Control SC-7](https://csrc.nist.gov/Projects/risk-management/sp800-53-controls/release-search#!/control?version=5.1&number=sc-7) includes this text:

> Connect to external networks or systems only through managed interfaces consisting of boundary protection devices arranged in accordance with an organizational security and privacy architecture.

Deploying this egress proxy in front of your cloud.gov application will help you meet this requirement!

See <docs/compliance/README.md> for information on the OSCAL documentation for this repo.
<!-- assorted keywords: nist rmf 800-53 fisma fedramp sc-7 gsa boundary egress -->
</details>

---

## Deployment architecture

```mermaid
    C4Context
      title controlled egress proxy for Cloud Foundry spaces
      Boundary(system, "system boundary") {
          Boundary(trusted_local_egress, "egress-controlled space", "trusted_local_networks_egress ASG") {
            System(application, "Application", "main application logic")
          }

          Boundary(public_egress, "egress-permitted space", "public_networks_egress ASG") {
            System(https_proxy, "web egress proxy", "proxy for HTTP/S connections")
          }
      }

      Boundary(external_boundary, "external boundary") {
        System(external_service, "external service", "service that the application relies on")
      }

      Rel(application, https_proxy, "makes request", "HTTP/S")
      Rel(https_proxy, external_service, "proxies request", "HTTP/S")
```

## Deployment options

### Terraform module (preferred)

Creates and configures an instance of cg-egress-proxy to proxy traffic from your apps. Each `client_configuration` has a separate set of credentials that's returned

Prerequite: an existing public-egress space to deploy the proxy into.

```terraform
module "egress_proxy" {
  source = "github.com/GSA-TTS/cg-egress-proxy?ref=GIT_SHA"

  cf_org_name          = local.cf_org_name
  cf_egress_space      = data.cloudfoundry_space.egress_space
  name                 = "egress-proxy"
  client_configuration = {
    "client-name" = {
      ports     = [443]
      allowlist = ["list.of.hosts.to", "*.allow.access"]
      denylist  = ["deny.allow.access"]
    }
  }
  # see variables.tf for full list of optional arguments
}

# connect the egress proxy to your app:

# setup routing from the client-name app:
resource "cloudfoundry_network_policy" "egress_routing" {
  policies = [
    {
      source_app      = cloudfoundry_app.client-name.id
      destination_app = module.egress_proxy.app_id
      port            = "61443"
    }
  ]
}

# create a user-provided service instance to store credentials in app's space
# you must also bind this service_instance to your app
resource "cloudfoundry_service_instance" "egress-credentials" {
  name        = "egress-credentials"
  space       = data.cloudfoundry_space.app_space.id
  type        = "user-provided"
  credentials = module.egress_proxy.json_credentials
  # see outputs.tf for the full list of outputs returned to the calling module,
  # especially in cases with multiple client_configuration entries
}
```

There is an example of deploying the proxy for a [two-client config](https://github.com/GSA-TTS/gitlab-runner-cloudgov/blob/09bb1b95f3a92687caccba4fdea82754228c0d64/main.tf#L162-L227) in the gitlab-runner-cloudgov repo. This example includes deploying the proxy, setting up network policies, and storing the proxy credentials in user-provided service instances.

### `bin/cf-deployproxy`

The deploy script in `bin` will deploy a separate instance of the cg-egress-proxy for each application that requires egress. This method is only recommended for applications that are not managed with IaC.

Run `bin/cf-deployproxy -h` for usage instructions

### `terraform-cloudgov` Terraform module (deprecated)

See the [terraform-cloudgov README](https://github.com/GSA-TTS/terraform-cloudgov?tab=readme-ov-file#egress_proxy) for usage instructions. This method is deprecated in favor of the terraform module in this repository.

### Deploying the proxy by hand (not recommended for production use)

Copy and edit the vars.yml-sample settings file. (Convention is to name it after your app.)

```bash
$ cp vars.yml-sample vars.myapp.yml
$ $EDITOR vars.myapp.yml
```

The values for proxydeny and proxyallow should consist of the relevant entries for your app, separated by spaces or newlines. Entries can be hostnames, IPs, or ranges for both, and can be expressed in many different forms. For examples, see [the upstream documentation](https://github.com/caddyserver/forwardproxy/blob/caddy2/README.md#caddyfile-syntax-server-configuration).

Deploy the proxy in a neighboring space with public egress. (Or optionally deploy it in another org altogether.)

```bash
$ cf target -s prod-egress [-o otherorg]
$ cf push --vars-file vars.myapp.yml
```

Enable your client to connect to the proxy. [Port 61443 implicitly terminates TLS for the proxy.](https://docs.cloudfoundry.org/concepts/understand-cf-networking.html#securing-traffic)

```bash
cf target -s prod [-o yourorg]
cf add-network-policy app myproxy --protocol tcp --port 61443 -s prod-egress [-o otherorg]
```

Help your app find the the proxy:

1. Set an environment variable with the proxy details:

        $ cf set-env egress_proxy  'https://user:pass@myproxy.app.internal:61443'

2. Or use a [user-provided service](https://docs.cloudfoundry.org/devguide/services/user-provided.html) to provide the URLs to your app.

Set up a [`.profile` file](https://docs.cloudfoundry.org/devguide/deploy-apps/deploy-app.html#profile) to set these variables during your app's initialization from either `$egress_proxy` or the user-provided service.

    ```bash
    #!/bin/bash
    # for example, from $egress_proxy
    export http_proxy="$egress_proxy"
    export https_proxy="$egress_proxy"
    ```

## Accounting for multiple internal apps that need to talk to one another internally

If you have multiple applications (e.g., an API and a front-end client) that each have a proxy in front of them, you will also need to configure them to explicitly not use the proxy to ensure that container-to-container traffic is permitted via the network policies you have set up.

In addition to the `http_proxy` and `http_proxy` environment variables, you'll also need to set the `no_proxy` environment variable in your app's initialization:
    ```bash
    #!/bin/bash
    export http_proxy="https://user:pass@myproxy.app.internal:61443"
    export https_proxy="https://user:pass@myproxy.app.internal:61443"
    export no_proxy="apps.internal"
    ```

Setting `no_proxy` to `apps.internal` will enable your apps to properly connect to one another within the platform; they'll automatically handle the ports and such.

You may also need to configure your apps to trust the system CA certs. (A typical error message you might see in this case: "SSL handshake failed: unable to find valid certification path to requested target.") This typically means setting an env variable with a path to the system certs. Depending on the base image or Cloud Foundry stack, the system CA bundle may be located at different paths, e.g., /etc/ssl/certs/ca-certificates.crt (Debian/Ubuntu-based images) or /etc/ssl/certs/ca-bundle.crt (RHEL/CentOS/Amazon Linux-based images).

Please see [this GitLab article for more information about `no_proxy`](https://about.gitlab.com/blog/2021/01/27/we-need-to-talk-no-proxy/) and the state of HTTP proxy configuration in general.

## Proxying S3 Bucket access
The deployment utility will also automatically ensure that apps can reach the domain corresponding to any S3 bucket services that are bound to them.

To use the AWS CLI `aws s3` subcommand, [set the `AWS_CA_BUNDLE` environment variable to ensure that the cloud.gov platform-provided certificate bundle is used](https://cloud.gov/knowledge-base/2022-11-04-fixing-certificate-errors-aws-egress-proxy/). For example:
```bash
AWS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt aws s3 ls [...]
```

Similarly, you have to add the content of the files in `$CF_SYSTEM_CERT_PATH/*` to the CA trust store for your application. We've looked up examples of doing that for [Go](https://forfuncsake.github.io/post/2017/08/trust-extra-ca-cert-in-go-app/), [Python](https://appdividend.com/2020/06/19/python-certifi-example-how-to-use-ssl-certificate-in-python/), [Ruby](https://docs.ruby-lang.org/en/2.4.0/OpenSSL/X509/Store.html), [PHP](https://stackoverflow.com/a/70318246), and [Java](https://stackoverflow.com/a/62508063).

## Troubleshooting

Test that curl connects properly from your application's container.

```bash
# Get a shell inside the app
$ cf ssh app -t -c "/tmp/lifecycle/launcher /home/vcap/app /bin/bash {}"

# Set http(s)_proxy env variables
$ . export_http_proxy.sh [CLIENT_NAME]

# Use curl to test that the container can reach things it should
$ curl http://allowedhost:allowedport
[...response from allowedhost...] # allowed

$ curl https://allowedhost:allowedport
[...response from allowedhost...] # allowed

# Use curl to test that the container can't reach things it shouldn't
$ curl http://allowedhost:deniedport
curl: (56) Received HTTP code 403 from proxy after CONNECT # denied

$ curl http://deniedhost:allowedport
curl: (56) Received HTTP code 403 from proxy after CONNECT # denied

$ curl https://allowedhost:deniedport
curl: (56) Received HTTP code 403 from proxy after CONNECT # denied

$ curl https://deniedhost:allowedport
curl: (56) Received HTTP code 403 from proxy after CONNECT # denied
```

If that all looks OK: Remember, your app must implicitly or explicitly make use of use the `https_proxy` environment variable when making connections to an allowedhost. Are you sure it's doing that?

If not, then it's time to see if connections are properly allowed/denied from the proxy itself. Test that it works by SSH'ing and allowing the `.profile` to load.

```bash
# Set up the exact same environment used by the proxy
$ cf ssh myapp -t -c "/tmp/lifecycle/launcher /home/vcap/app /bin/bash {}"

  # Within the resulting shell...
  $ curl https://allowedhost
  [...response from allowedhost...] # allowed

  $ curl https://notallowedhost
  curl: (56) Received HTTP code 403 from proxy after CONNECT  # denied

  # If something doesn't seem to be working right, add the -I and -v flags
  $ curl -I -v https://deniedhost
  [...pretty straightforward rejection from the proxy right after CONNECT...]
  $ curl -I -v https://allowedhost
  [...debugging info...]
```

If that _doesn't_ look OK: You may be using the proxy in a new or unexpected way, or you may have found a bug. Please file an issue or otherwise contact the project's maintainers!

### Language references

Gotchas found in each application language can be found within the [docs](./docs) folder.

## How it works

- The proxy runs [Caddy V2](https://caddyserver.com)
  - Caddy is compiled to include the [forwardproxy](https://github.com/caddyserver/forwardproxy) plugin
  - `.profile` copies the config from `$CONFIG_CONTENT` _or_ creates `deny.acl` and `allow.acl` files based on environment variables.
  - Caddy's `forward_proxy` directive refers to those rules with `allow`, `deny`, `deny_file`, and `allow_file`.
- Caddy listens on one port: $PORT
  - Caddy is configured to use the c2c certificate for terminating TLS.
  - After TLS termination, Caddy sees plaintext for the _inital_ client connection, until it receives `CONNECT`. After that exchange, per the proxying spec:
  - It CAN   see the content of requests to http://  destinations
  - It CAN'T see the content of requests to https:// destinations
    - The TLS exchange between the client and destination happens post-`CONNECT` directly over a TCP tunnel. Caddy just sends and receives the bytes.
- An `apps.internal` route makes the proxy resolveable by other applications.
- Apps cannot actually send bytes to the proxy's port without an explicit `cf add-network-policy app proxy --protocol tcp --port 61443 -s proxy-space -o proxy-org`.
- An appropriate network policy can only be created by someone with SpaceDeveloper permissions in both the source and destination space.

## For local development

A custom Caddy binary with a forward-proxy plugin is included in the `proxy/` directory. If you ever need to rebuild the Caddy binary yourself locally, run:

```bash
$ make
```


## Local testing

1. Run `docker compose build`. If running on an ARM machine, such as an Apple Silicon Mac, run `docker compose build --build-arg GOARCH=arm`
1. Run `docker compose up`
1. Test allowed and denied destinations and ports (TODO: This should just run a script inside the container):
    ```bash
    docker-compose exec caddy curl https://allowedhost:allowedport # (allowed) PASS
    docker-compose exec caddy curl https://allowedhost:deniedport # (denied) PASS
    docker-compose exec caddy curl https://deniedhost:allowedport # (denied) PASS
    ```
1. Run `docker compose down`

### If you want to hand test using your browser...
_NOTE: This information is out of date, and needs updating... PRs welcome!_

Caddy is configured to listen on port 8080 and does not attempt tls. This means you must set `https_proxy` to a value that starts with `http://`.

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md) for additional information.

## Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
