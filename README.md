# nf-mod-parabricks

Nextflow module for NVIDIA Clara Parabricks (GPU-accelerated alignment and variant calling). Used as a git submodule by pipelines.

Image: `nvcr.io/nvidia/clara/clara-parabricks (NVIDIA NGC; this repo ships no image)`

## Processes

Each subtool lives in its own folder (nf-core style), with a `main.nf`, a
`meta.yml` and an nf-test case under `tests/`.

| Process | Path | Inputs | Emits |
| --- | --- | --- | --- |
| `PARABRICKS_DEEPVARIANT` | `deepvariant/main.nf` | `tuple val(meta), path(bam), path(bai)`<br>`tuple path(fasta), path(fai)` | `vcf` |
| `PARABRICKS_FQ2BAM` | `fq2bam/main.nf` | `tuple val(meta), path(r1), path(r2)`<br>`tuple path(fasta), path(fasta_index)` | `bam`, `dup_metrics` |
| `PARABRICKS_MARKDUP` | `markdup/main.nf` | `tuple val(meta), path(bam)`<br>`tuple path(fasta), path(fai)` | `bam`, `dup_metrics` |
| `PARABRICKS_MINIMAP2` | `minimap2/main.nf` | `tuple val(meta), path(fastq)`<br>`tuple path(fasta), path(fai)` | `bam` |
| `PARABRICKS_MUTECTCALLER` | `mutectcaller/main.nf` | `tuple val(meta), path(bam), path(bai)`<br>`tuple path(fasta), path(fai)` | `vcf` |

## Publishing

These processes do **not** publish their own outputs. Publishing is the
consuming pipeline's job, via a workflow `output {}` block. This keeps the
module reusable across pipelines that want different result layouts.

## Tool arguments

Flags are passed through `task.ext.args` (and `args2`/`args3` where a process
runs more than one command) rather than read from pipeline `params`, so the
module never depends on a particular pipeline's parameter names:

```groovy
process {
    withName: PARABRICKS_DEEPVARIANT {
        ext.args = '--some-flag'
    }
}
```

## Use as submodule

Pin to a release tag rather than a branch, so pipeline runs stay reproducible:

```bash
git submodule add https://github.com/EIT-GBI/nf-mod-parabricks.git modules/parabricks
git -C modules/parabricks checkout v1.0.0
```

Then include the module's container config from your `nextflow.config`. Nextflow
does not read a submodule's config on its own, so without this line the
processes have no image:

```groovy
includeConfig 'modules/parabricks/conf/module.config'
```

`conf/module.config` pins the image to the version built from this same commit,
and carries no `manifest {}` block, so it will not overwrite your pipeline's
own manifest. Override it in your pipeline with a `withName` selector if needed.

And include the processes:

```groovy
include { PARABRICKS_DEEPVARIANT } from './modules/parabricks/deepvariant/main.nf'
include { PARABRICKS_FQ2BAM } from './modules/parabricks/fq2bam/main.nf'
include { PARABRICKS_MARKDUP } from './modules/parabricks/markdup/main.nf'
include { PARABRICKS_MINIMAP2 } from './modules/parabricks/minimap2/main.nf'
include { PARABRICKS_MUTECTCALLER } from './modules/parabricks/mutectcaller/main.nf'
```

## Requirements

Nextflow 26.04.4 or newer.

## Releasing

Merging a PR to `main` with exactly one `bump:patch`, `bump:minor` or
`bump:major` label bumps `manifest.version` in `nextflow.config`, tags the
release and publishes the container image.
