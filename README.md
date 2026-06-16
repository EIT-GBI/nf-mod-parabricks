# nf-mod-parabricks


Nextflow module for parabricks. Used as a git submodule by pipelines.

Image: `ghcr.io/eit-gbi/nf-mod-parabricks:latest`

## Processes

- `PARABRICKS` — TODO: describe inputs/outputs

## Use as submodule
```bash
git submodule add https://github.com/eit-gbi/nf-mod-parabricks.git modules/parabricks
```

Then in your pipeline:
```
include { PARABRICKS } from './modules/parabricks/main.nf'
```
