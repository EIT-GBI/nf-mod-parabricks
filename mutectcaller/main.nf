// GPU somatic variant calling step using Mutect2

process MUTECTCALLER {
    tag "${meta.id}"
        
    publishDir "${params.outdir}/variants/mutect", mode: 'link'

    input:
        tuple val(meta), path(bam), path(bai)
        tuple path(fasta), path(fai)

    output:
        tuple val(meta), path("${meta.id}.mutect.vcf"), emit: vcf

    script:
    def args = task.ext.args ?: ""
    """
    pbrun mutect2 \\
        ${args} \\
        --ref ${fasta} \\
        --in-bam ${bam} \\
        --out-vcf ${meta.id}.mutect.vcf \\
        --num-gpus ${task.ext.num_gpus ?: 1}
    """

    stub:
    """
    touch ${meta.id}.mutect.vcf
    """
}
