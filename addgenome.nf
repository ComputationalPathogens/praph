#!/usr/bin/env nextflow
params.datadir = "$baseDir"
params.toadd = 1005
params.pantoolsjar = "/home/liam/praph/pantools/dist/pantools.jar"

nextflow.enable.dsl = 2

include { PROCESSFILES } from './workflow/processfiles'
include { DOWNLOAD } from './workflow/download'
include { BUILDPG } from './workflow/buildpg'
workflow {
		PROCESSFILES(params.datadir)
		GETGENOME(PROCESSFILES.out, params.toadd)
        ADDGTOPG(GETGENOME.out, params.pantoolsjar)
}

workflow.onComplete {
	log.info ( workflow.success ? "\nDone!" : "Oops .. something went wrong" )
}

process GETGENOME {
	echo true
	input:
	  val(datadir)
	  val(toadd)

	output:
	  stdout emit: out

    script:
    """
    #!python3
    import sys
    import pandas as pd
    import numpy as np
    import os
    genomes = pd.read_csv("$datadir"+'/processed_data/metadata.csv', ',', names=['A','B','C','D','E','F','G'])
    selected = genomes.E.tolist()
    selected = selected[$toadd]
    selected = '$datadir' + str(selected)
    selected = [selected]
    np.savetxt("$datadir/toadd.txt", selected, fmt= "%s")

    print("$datadir", end = '')
    """
}

process ADDGTOPG {
    echo true
    input:
        val(datadir)
        val(pantoolsjar)
    
    output:
        val(datadir)
    
    script:
    """
    java -Xms90g -Xmx90g -jar $pantoolsjar add_genomes -dp $datadir/database -gf $datadir/toadd.txt
    """
}