// GPU-accelerated version of minimap2 for long-read alignment


process PARABRICKS_MINIMAP2 {
    tag "${meta.id}"
        
    publishDir "${params.outdir}/alignment", mode: 'link'

    input:
        tuple val(meta), path(fastq)
        tuple path(fasta), path(fai)

    output:
        tuple val(meta), path("${meta.id}.sorted.bam"), path("${meta.id}.sorted.bai"), emit: bam

    script:
    def args = task.ext.args ?: ""
    """
    pbrun minimap2 \\
        ${args} \\
        --preset ${meta.preset} \\
        --ref ${fasta} \\
        --in-fq ${fastq} \\
        --read-group-sm ${meta.id} \\
        --out-bam ${meta.id}.sorted.bam \\
        --num-gpus ${task.accelerator?.request ?: 1}

    samtools index -@ ${task.cpus ?: 1} ${meta.id}.sorted.bam
    """

    stub:
    """
    touch ${meta.id}.sorted.bam
    touch ${meta.id}.sorted.bai
    """
}