// GPU alignment with NVIDIA's Clara Parabricks 'fq2bam' tool
// This is the equivalent of the 'bwa mem' command, but runs on NVIDIA GPUs 

process PARABRICKS_FQ2BAM {
    tag "${meta.id}"
        
    publishDir "${params.outdir}/alignment", mode: 'link'

    input:
        tuple val(meta), path(r1), path(r2)
        tuple path(fasta), path(fasta_index)

    output:
        tuple val(meta), path("${meta.id}.sorted.bam"), path("${meta.id}.sorted.bam.bai"), emit: bam
        tuple val(meta), path("${meta.id}.dup_metrics.txt"), emit: dup_metrics

    script:
    def args = task.ext.args ?: ""
    """
    pbrun fq2bam \\
        ${args} \\
        --ref ${fasta} \\
        --in-fq ${r1} ${r2} "@RG\\tID:${meta.id}\\tSM:${meta.id}\\tPL:ILLUMINA\\tLB:${meta.id}" \\
        --out-bam ${meta.id}.sorted.bam \\
        --out-duplicate-metrics ${meta.id}.dup_metrics.txt \\
        --num-gpus ${task.accelerator?.request ?: 1}
    """

    stub:
    """
    touch ${meta.id}.sorted.bam ${meta.id}.sorted.bam.bai ${meta.id}.dup_metrics.txt
    """
}