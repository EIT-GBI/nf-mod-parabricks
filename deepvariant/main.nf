// GPU germline variant calling step using DeepVariant

process PARABRICKS_DEEPVARIANT {
    tag "${meta.id}"
        
    publishDir "${params.outdir}/variants/deepvariant", mode: 'link'

    input:
        tuple val(meta), path(bam), path(bai)
        tuple path(fasta), path(fai)

    output:
        tuple val(meta), path("${meta.id}.deepvariant.vcf"), emit: vcf

    script:
    def args = task.ext.args ?: ""
    """
    pbrun deepvariant \\
        ${args} \\
        --ref ${fasta} \\
        --in-bam ${bam} \\
        --out-vcf ${meta.id}.deepvariant.vcf \\
        --num-gpus ${task.accelerator?.request ?: 1}
    """

    stub:
    """
    touch ${meta.id}.deepvariant.vcf
    """
}