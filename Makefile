SHELL=/bin/bash -e -x

# develop this Makefile in a cloud workstation, as sudo, since this Makefile will be executed as root:
# dx run kccg:/cloud_workstation -imax_session_length=120 --ssh --yes
# unset DX_WORKSPACE_ID
# dx cd $DX_PROJECT_CONTEXT_ID:
# sudo -s

all:
	#
	# install R 3.2.3 from source (http://askubuntu.com/a/798731)
	#
	wget https://cran.rstudio.com/src/base/R-3/R-3.2.3.tar.gz
	tar -xf R-3.2.3.tar.gz
	which gcc || apt-get --yes install gcc
	which f77 || DEBIAN_FRONTEND=noninteractive apt-get --yes install fort77
	which g++ || apt-get --yes install g++
	which gfortran || apt-get --yes install gfortran
	which java || DEBIAN_FRONTEND=noninteractive apt-get install --yes openjdk-7-jre-headless openjdk-7-jdk
	#apt-get --yes install xorg-dev	# many dependencies; likely not needed in a headless environment
	DEBIAN_FRONTEND=noninteractive apt-get install libopenblas-base
	
	cd ./R-3.2.3 && ./configure --with-x=no --with-blas 1>&2
	$(MAKE) -C ./R-3.2.3 -j4
	ln -s /usr/lib/libblas.so.3 ./R-3.2.3/lib/libRblas.so
	$(MAKE) -C ./R-3.2.3 install
	R --version 1>&2
	ldd /usr/local/lib/R/bin/exec/R 1>&2

	#
	# install VCFscope's CRAN & Bioconductor dependencies
	#
	R -e "update.packages(repos='http://cran.rstudio.com/', ask=FALSE)"
	R -e "install.packages(c('testthat', 'memoise', 'crayon', 'digest', 'inline', 'Rcpp'), repos='http://cran.rstudio.com/')"
	R -e "source('http://bioconductor.org/biocLite.R'); biocLite(); biocLite(c('VariantAnnotation', 'BSgenome'))"
	# custom BSgenome, located within the "VCFscope resources" DNAnexus project. 
	# THE URL will stop working after 20/12/2018
	wget https://dl.dnanex.us/F/D/j1Y3PXb9qK78Qxpg9xykpQqF584J3gV20Y23gZ1f/BSgenome.HSapiens.1000g.37d5_1.0.0.tar.gz
	R CMD INSTALL BSgenome.HSapiens.1000g.37d5_1.0.0.tar.gz

# we have already included binaries for bcftools, bedtools, bgzip, tabix, samtools.
# RTG is included in vcfscope_reporter_resources_bundle-2.0.tar
# TODO: build them here and remove them from vcfscope's dx app.
