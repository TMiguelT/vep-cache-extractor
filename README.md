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

```bash
Usage: download.sh -c cache_type -e ensembl_release -g genome-build
  -c, --cache-type
    The version of the cache to download. Either 'merged', 'ensembl' or 'refseq'
  -e, --ensembl-release
    The ensembl release number to download the cache for. e.g. 75, 85 etc.
  -g, --genome-build
    The grch build version to download for. e.g. 37, 38
```

## Usage
Use the script as follows:
```bash
perl extract.pl /path/to/cache path_1:column_1 path_2:column_2
```
In other words, the script's first argument is a directory path indicating where
the cache is located.

The second and all following arguments are descriptors indicating which field you
want to extract from the cache and what to name them. Each argument is a pair of
path:column_name pairs. For example, this second argument might be `_trans_exon_array.0.stable_id:exon_id` (explained below)

* `path`: A dot separated string, where each segment is a hash key, indicating
which field to choose. For example, `"_trans_exon_array.0.stable_id"` would choose the stable_id of the first exon
in the transcript, which in json terms means extract `transcript["_trans_exon_array"][0][stable_id]` for each transcript.
You might find it helpful to look at the sample.json file in the repository, as this will give you some indication as to which fields are stored in the VEP cache.
* `column_name`: A string indicating the name of the column to store this data in.
For example, if we used the path above, along with the column_name of "exon_id",
we would get output as follows:
```
exon_id
"id67641"
"id67642"
"NM_152663.3.1"
"XM_005245297.1.1"
"id67643"
"id67663"
"ENSESTE00000219503"
"ENSESTE00000220088"
```
