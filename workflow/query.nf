process GENEDIFF {
    echo true
    input:
      val(datadir)
      
    output:
      val(datadir)
    
    script:
    """
    java -jar /home/liam/praph/pantools/dist/pantools.jar gene_classification -dp $datadir/database -ph species
    """
}

workflow QUERY {
	take:
	  datadir

	main:
	  GENEDIFF(datadir)

	  
	emit:
	  GENEDIFF.out

}