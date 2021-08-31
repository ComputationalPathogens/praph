

process DOWNLOAD {
	input:
	  val(datadir)
	  val(genera)
	  val(formats)

	output:
	  val(datadir)

	script:
	"""
	ncbi-genome-download --formats "$formats" --genera "$genera" bacteria --parallel 12 -o "$datadir"
	"""
}