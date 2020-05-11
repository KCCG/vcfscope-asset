#!/bin/bash
set -exuo pipefail
IFS=$'\n'

# which gcc || apt-get --yes install gcc
# which f77 || env DEBIAN_FRONTEND=noninteractive apt-get --yes install fort77
# which g++ || apt-get --yes install g++
# which gfortran || apt-get --yes install gfortran
# which java || env DEBIAN_FRONTEND=noninteractive apt-get install --yes openjdk-7-jre-headless openjdk-7-jdk
# #apt-get --yes install xorg-dev # many dependencies; likely not needed in a headless environment
# env DEBIAN_FRONTEND=noninteractive apt-get install libopenblas-base

#
# install R 3.2.3 from source (http://askubuntu.com/a/798731)
#
RNAME="R-3.2.3"
[ -d $RNAME ] || curl -L https://cran.rstudio.com/src/base/R-3/${RNAME}.tar.gz | tar zx
(cd $RNAME && ./configure --with-x=no --with-blas --with-lapack 1>&2 --prefix=$PWD/install)
make -C $RNAME -j4
make -C $RNAME install

R=$PWD/$RNAME/install/bin/R
$R --version 1>&2
# ldd $R 1>&2

#
# install VCFscope's CRAN & Bioconductor dependencies

# this is the old way, that no longer works due to version updates:
# R -e "update.packages(repos='http://cran.rstudio.com/', ask=FALSE)"
# R -e "install.packages(c('testthat', 'memoise', 'crayon', 'digest', 'inline', 'Rcpp'), repos='http://cran.rstudio.com/')"
# R -e "source('http://bioconductor.org/biocLite.R'); biocLite(); biocLite(c('VariantAnnotation', 'BSgenome'))"

tar xf vcfscope-asset-deps.tar

for d in $( cat deps ); do
    dep=$(basename $d)
    # This downloads the same content as vcfscope-asset-deps.tar
    # cran.r-project.org annoyingly moves their urls, so try up 2 levels also
    [ -f $dep ] || wget $d || wget $(dirname $(dirname $(dirname $d)))/$(basename $d)
    $R CMD INSTALL $dep
done

# custom BSgenome, located within the "VCFscope resources" DNAnexus project. 
# THE URL will stop working after 20/12/2018
[ -f BSgenome.HSapiens.1000g.37d5_1.0.0.tar.gz ] || wget https://dl.dnanex.us/F/D/j1Y3PXb9qK78Qxpg9xykpQqF584J3gV20Y23gZ1f/BSgenome.HSapiens.1000g.37d5_1.0.0.tar.gz
$R CMD INSTALL BSgenome.HSapiens.1000g.37d5_1.0.0.tar.gz

# we have already included binaries for bcftools, bedtools, bgzip, tabix, samtools.
# RTG is included in vcfscope_reporter_resources_bundle-2.0.tar
# TODO: build them here and remove them from vcfscope's dx app.
