// GPU alignment with NVIDIA's Clara Parabricks 'fq2bam' tool
// This is the equivalent of the 'bwa mem' command, but runs on NVIDIA GPUs 

process PARABRICKS_FQ2BAM {
    tag "${meta.id}"
        

    input:
        tuple val(meta), path(r1), path(r2)
        tuple path(fasta), path(fasta_index)

    output:
        tuple val(meta), path("${meta.id}.sorted.bam"), path("${meta.id}.sorted.bam.bai"), emit: bam
        tuple val(meta), path("${meta.id}.dup_metrics.txt"), emit: dup_metrics

    script:
    def args = task.ext.args ?: ""
    """
    # pbrun resolves --ref to its real path and then looks for the BWA index
    # beside *that* file. Nextflow stages inputs as symlinks, so pointing it at
    # the staged reference makes it look next to the original instead, where an
    # index built by BWA_INDEX does not exist.
    #
    # If the original is already indexed, use it as-is. Otherwise gather real
    # copies of the reference and its index into one directory here, so the two
    # sit together wherever pbrun resolves them to.
    ref=\$(readlink -f ${fasta})
    if [ ! -e "\${ref}.bwt" ]; then
        mkdir -p pbref
        cp -L ${fasta} pbref/${fasta}
        # every staged sibling: the bwa index and the .fai
        for f in ${fasta}.*; do
            [ -e "\$f" ] && cp -L "\$f" pbref/
        done
        # and the .fai from beside the original, if it only exists there
        [ -e "\${ref}.fai" ] && [ ! -e "pbref/${fasta}.fai" ] && cp -L "\${ref}.fai" pbref/
        ref="\$PWD/pbref/${fasta}"
        echo "Reference materialised for pbrun:"
        ls -1 pbref/
    fi

    pbrun fq2bam \\
        ${args} \\
        --ref "\$ref" \\
        --in-fq ${r1} ${r2} "@RG\\tID:${meta.id}\\tSM:${meta.id}\\tPL:ILLUMINA\\tLB:${meta.id}\\tPU:${meta.id}" \\
        --out-bam ${meta.id}.sorted.bam \\
        --out-duplicate-metrics ${meta.id}.dup_metrics.txt \\
        --num-gpus ${task.accelerator?.request ?: 1}
    """

    stub:
    """
    touch ${meta.id}.sorted.bam ${meta.id}.sorted.bam.bai ${meta.id}.dup_metrics.txt
    """
}