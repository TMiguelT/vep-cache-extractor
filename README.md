# VEP Cache Extractor
## Introduction
The VEP cache extractor is a command line utility for extracting fields from the
cache used by Ensembl's VEP, or [Variant Effect Predictor](http://asia.ensembl.org/info/docs/tools/vep/index.html)
tool. The cache itself is a large collection of Perl storable files, each
containing a large list of transcript entries.

## Installation
To install the script's dependencies, make sure cpanm is installed with
```bash
cpan App::cpanminus
```
and then install the dependencies using
```bash
cpanm --installdeps .
```

You'll also need a copy of the VEP cache itself. You may already have one if
you're already using VEP, but you'll still need to unzip all the files  but if not, use the installer script to download it
(documented below).

## Downloader Script
This script downloads a certain version of the VEP cache into the repository
directory (the same directory as the script). Use it as follows:

Usage: download.sh -c cache_type -e ensembl_release -g genome-build
  -c, --cache-type
    The version of the cache to download. Either 'merged', 'ensembl' or 'refseq'
  -e, --ensembl-release
    The ensembl release number to download the cache for. e.g. 75, 85 etc.
  -g, --genome-build
    The grch build version to download for. e.g. 37, 38

## Usage
Use the script as follows:
```bash
perl extract.pl /path/to/cache
