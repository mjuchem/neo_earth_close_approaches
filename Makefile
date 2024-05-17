all: download pdf 3d

download:
	Rscript 1_download-dataset.R --vanilla

pdf:
	Rscript 2_pdf-report.R --vanilla

3d:
	Rscript 3_3d-report.R --vanilla
