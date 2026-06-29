// NVIDIA Paracbricks MarkDuplicates tool

process PARABRICKS_MARKDUP {
    tag "${meta.id}"

    publishDir "${params.outdir}/alignment", mode: 'link'

    input:
        tuple val(meta), path(bam)
        tuple path(fasta), path(fai)

    output:
        tuple val(meta), path("${meta.id}.markdup.bam"), emit: bam
        tuple val(meta), path("${meta.id}.dup_metrics.txt"), emit: dup_metrics

    script:
    def args = task.ext.args ?: ""
    """
    pbrun markdup \\
        ${args} \\
        --ref ${fasta} \\
        --in-bam ${bam} \\
        --out-bam ${meta.id}.markdup.bam \\
        --out-duplicate-metrics ${meta.id}.dup_metrics.txt
    """"

    stub:
    """
    touch ${meta.id}.markdup.bam ${meta.id}.dup_metrics.txt
    """

}