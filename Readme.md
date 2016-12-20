This is a DNAnexus Asset Bundle [1,2], to support the running of VCFscope.

It essentially installs R 3.2.3, and the necessary dependencies.
If you're not using DNAnexus, then the Makefile should work on an Ubuntu 14.04 instance. The combination of dxasset.json and Makefile
creates a snapshot of a system, with the appropriate dependencies installed in the appropriate system locations.

# References
1. https://wiki.dnanexus.com/Developer-Tutorials/Asset-Build-Process
2. https://wiki.dnanexus.com/Asset-Bundle
