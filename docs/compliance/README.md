# Compliance artifacts for cg-egress-proxy

[cg-egress-proxy.json](./cg-egress-proxy.json) is an OSCAL Component Definition for cg-egress-proxy. You can import it
into your OSCAL SSP using [docker-trestle](https://github.com/GSA-TTS/docker-trestle)

Inside the docker-trestle CLI:

```bash
copy-component -n cg-egress-proxy -u https://raw.githubusercontent.com/GSA-TTS/cg-egress-proxy/refs/heads/main/docs/compliance/component-definitions/cg-egress-proxy/component-definition.json
```

## Development of OSCAL in this directory

To update the OSCAL component definition, utilize `docker-trestle` by running:

`docker run -it --rm -e SKIP_TRESTLE_CONFIG=true -v (pwd):/app/docs ghcr.io/gsa-tts/trestle bash`

from within the `docs/compliance` directory.

### Directory structure

#### bin

Helper scripts to be called from within the `docker-trestle` CLI for transforming the CD into markdown and back again.

#### component-definitions

The OSCAL json component definition files to be distributed.

#### control-statements

The markdown files for updating implementation statements
