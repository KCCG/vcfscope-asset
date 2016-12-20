SHELL=/bin/bash -e -x

# develop this Makefile in a cloud workstation:
# 
# unset DX_WORKSPACE_ID
# dx cd $DX_PROJECT_CONTEXT_ID:

all:
	# remove default R 3.0.2
	apt-get --yes remove r-base r-base-core r-base-dev r-base-html \
	r-cran-boot r-cran-class r-cran-cluster r-cran-codetools r-cran-foreign \
	r-cran-kernsmooth r-cran-lattice r-cran-mass r-cran-matrix r-cran-mgcv \
	r-cran-nlme r-cran-nnet r-cran-rpart r-cran-spatial r-cran-survival \
	r-doc-html r-recommended
	
	# Trust the signing key for this repox`. Reference: http://cran.rstudio.com/bin/linux/ubuntu/README.html
	# apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
	# cp /etc/apt/apt.conf.d/99dnanexus .
	# rm -f /etc/apt/apt.conf.d/99dnanexus
	
	which java || DEBIAN_FRONTEND=noninteractive apt-get install --yes openjdk-7-jre-headless openjdk-7-jdk

	# install R 3.2.3 from scratch (http://askubuntu.com/a/798731)
	wget https://cran.rstudio.com/src/base/R-3/R-3.2.3.tar.gz
	tar -xf R-3.2.3.tar.gz
	which gcc || apt-get --yes install gcc
	which f77 || DEBIAN_FRONTEND=noninteractive apt-get --yes install fort77
	which g++ || apt-get --yes install g++
	which gfortran || apt-get --yes install gfortran
	wget http://security.ubuntu.com/ubuntu/pool/main/i/icu/libicu52_52.1-8ubuntu0.2_amd64.deb
  sudo dpkg -i libicu52_52.1-8ubuntu0.2

	#apt-get --yes install libpng12-0 libpng12-dev
	#apt-get --yes install libjpeg62 libjpeg62-dev
	#apt-get --yes install libcairo2 libcairo2-dev
	#apt-get --yes install xorg-dev	# many dependencies; try without this
	
	cd ./R-3.2.3 && ./configure --with-x=no --prefix=/usr
	$(MAKE) -C ./R-3.2.3 -j4
	$(MAKE) -C ./R-3.2.3 install
	R --version 1>&2
	ldd /usr/lib/R/bin/exec/R 1>&2
	
	# install VCFscope dependencies, bioconductor and it's packages
	R -e "update.packages(repos='http://cran.rstudio.com/', ask=FALSE)"
	R -e "install.packages(c('testthat', 'memoise', 'crayon', 'digest', 'inline', 'Rcpp'), repos='http://cran.rstudio.com/')"
	R -e "source('http://bioconductor.org/biocLite.R'); biocLite(); biocLite(c('VariantAnnotation', 'BSgenome'))"
	R -e 'library(VariantAnnotation)'
	# custom BSgenome
	wget https://dl.dnanex.us/F/D/j1Y3PXb9qK78Qxpg9xykpQqF584J3gV20Y23gZ1f/BSgenome.HSapiens.1000g.37d5_1.0.0.tar.gz
	R CMD INSTALL BSgenome.HSapiens.1000g.37d5_1.0.0.tar.gz

	# we have already included binaries for bcftools, bedtools, bgzip, tabix, samtools.
	# RTG is included in vcfscope_reporter_resources_bundle-2.0.tar
	# TODO: build them here and remove them from vcfscope's dx app.
