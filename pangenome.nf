#!/usr/bin/env nextflow
params.download = true
params.datadir = "$baseDir"
params.n = 10
params.genera = "Brucella"
params.formats = "fasta,assembly-report,gff"

nextflow.enable.dsl = 2

include { PROCESSFILES } from './workflow/processfiles'
include { DOWNLOAD } from './workflow/download'
include { BUILDPG } from './workflow/buildpg'
include { QUERY } from './workflow/query'
workflow {
	if(params.download == true) {
		DOWNLOAD(params.datadir, params.genera, params.formats)
		PROCESSFILES(DOWNLOAD.out)
	} else {
		PROCESSFILES(params.datadir)
	}
        	BUILDPG(params.n, PROCESSFILES.out)
        QUERY(BUILDPG.out)
}

workflow.onComplete {
	log.info ( workflow.success ? "\nDone!" : "Oops .. something went wrong" )
}