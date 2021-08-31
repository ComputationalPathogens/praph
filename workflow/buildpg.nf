
process EXTRACTFL {
	echo true
	input:
	  val(n)
	  val(datadir)

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
    species = genomes.D.tolist()
    selected = selected[0:$n]
    species = species[0:$n]
    annotations = selected.copy()
    for s in range(len(selected)):
        species[s] = str(s+1) + ',' + str(species[s])
        selected[s] = '$datadir' + str(selected[s])
        annotations[s] = str(s+1) + " " + "$datadir" + str(os.path.splitext(annotations[s])[0]) + '.gff'
    selected = pd.DataFrame(selected)
    species.insert(0, 'Genome,species')
    species = pd.DataFrame(species)
    annotations = pd.DataFrame(annotations)
    selected.to_csv("$datadir/$n-genome-filepaths.txt", index = False, header=False)
    np.savetxt("$datadir/$n-genome-species.txt", species.values, fmt= "%s")
    annotations.to_csv("$datadir/$n-genome-annotations.txt", index=False, header=False)
    print("$datadir", end = '')
    """
}

process PANTOOLS {
    echo true
    input:
      val(n)
      val(datadir)
      
    output:
      val(datadir)
    
    script:
    """
    java -jar /home/liam/praph/pantools/dist/pantools.jar bpg -dp $datadir/database -gf $datadir/$n-genome-filepaths.txt
    """
}

process ANNOTATE {
    echo true
    input:
      val(n)
      val(datadir)
      
    output:
      val(datadir)
    
    script:
    """
    java -jar /home/liam/praph/pantools/dist/pantools.jar add_annotations -dp $datadir/database -af $datadir/$n-genome-annotations.txt
    java -jar /home/liam/praph/pantools/dist/pantools.jar group -dp $datadir/database -tn 32
    """
}

process PHENOTYPE {
    echo true
    input:
      val(n)
      val(datadir)
      
    output:
      val(datadir)
    
    script:
    """
    java -jar /home/liam/praph/pantools/dist/pantools.jar add_phenotype -dp $datadir/database -ph $datadir/$n-genome-species.txt
    """
}

workflow BUILDPG {
	take:
	  n
	  datadir

	main:
	  EXTRACTFL(n, datadir)
	  PANTOOLS(n, EXTRACTFL.out)
	  ANNOTATE(n, PANTOOLS.out)
	  PHENOTYPE(n, ANNOTATE.out)
	emit:
	  PHENOTYPE.out

}