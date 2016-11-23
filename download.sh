#!/usr/bin/env bash

# Parse arguments using gnu getopt
ARGS=$(getopt -o e:c:g: --long "ensembl-release:,cache-type:l,usage,help,genome-build" -n $(basename $0) -- "$@")
eval set -- "$ARGS"

# Define terminal formatting sequences
bold=$(tput bold)
normal=$(tput sgr0)

# Usage print function
function usage {
  echo "${bold}Usage: $(basename $0) -c cache_type -e ensembl_release -g genome-build"
  echo "  ${bold}-c, --cache-type"
  echo "    ${normal}The version of the cache to download. Either 'merged', 'ensembl' or 'refseq'"
  echo "  ${bold}-e, --ensembl-release"
  echo "    ${normal}The ensembl release number to download the cache for. e.g. 75, 85 etc."
  echo "  ${bold}-g, --genome-build"
  echo "    ${normal}The grch build version to download for. e.g. 37, 38"
}

# Parse the arguments
while true ; do
    case "$1" in
        -e|--ensembl-release)
          ENSEMBL_RELEASE=$2
          shift 2;;
        -c|--cache-type)
          case $2 in
            merged) CACHE_TYPE="homo_sapiens_merged_vep";;
            ensembl) CACHE_TYPE="homo_sapiens_vep";;
            refseq) CACHE_TYPE="homo_sapiens_refseq_vep";;
            *) usage; exit 1;;
          esac
          shift 2 ;;
        -g|--genome-build)
          GENOME_BUILD=$2
          shift 2 ;;
        --usage|--help)
          usage
          exit 0;;
        --)
          shift
          break ;;
        *)
          usage
          exit 1 ;;
    esac
done

# Ensure all arguments have been given
if [[ -z $ENSEMBL_RELEASE ]] || [[ -z $CACHE_TYPE ]] || [ -z $GENOME_BUILD ] ; then
    usage
    exit 1
fi

echo -n "Downloading VEP cache..."

# Make the parent directory
mkdir -p $(dirname $0)/vep_cache
# Choose the URL based on the ENSEMBL release
if [[ $(( $ENSEMBL_RELEASE <= 75 )) == 1 ]] ; then
    URL=ftp://ftp.ensembl.org/pub/release-${ENSEMBL_RELEASE}/variation/VEP/${CACHE_TYPE}_${ENSEMBL_RELEASE}.tar.gz
else
    URL=ftp://ftp.ensembl.org/pub/release-${ENSEMBL_RELEASE}/variation/VEP/${CACHE_TYPE}_${ENSEMBL_RELEASE}_GRCh${GENOME_BUILD}.tar.gz 
fi

# Do the download
curl $URL | tar -xz -C $(dirname $0)/vep_cache
echo "Done."

