# HybSeq-Cleaning
Scripts for reducing downstream model violations in target-enrichment data

### Finding redundancy in HybSeq assemblies

Some target-enrichment library kits may have probes that hybridize to multiple exons from the same gene. These would be assembled as separate loci from assembly pipelines that use the reference sequences to bait the assemblies. This might be innocuous for some phylogenetic analyses such as concatenated maximum likelihood - there is nothing wrong with loci of variable length after all. However, I think it might be problematic for some coalescent analyses, for example species trees under the multispecies coalescent, or some population genetic applications, for example analyses of population structure that use a single SNP per locus. This might unfairly treat data in tight linkage as independent.

When there are probes across multiple exons of the same gene, their intronic "splash" regions might overlap. We can find where assembled loci bleed into each other by dumping the assemblies for all loci from all species into a single fasta file and doign an all-by-all blast search. Here are some example blast commands from Tiley et al. (2023):

```
makeblastdb -in loudetia.fasta -out loudetia -parse_seqids -dbtype nucl
blastn -query loudetia.fasta -db loudetia -max_target_seqs 5 -max_hsps 1 -evalue 1e-5 -outfmt "6 qacc sacc pident length mismatch gapopen qstart qend sstart send evalue bitscore" -num_threads 4 -out loudetia.blast.out
```
 
Note that I specify a custom field for the blast output. This is important for the downstream blast parsing, but it might overlap with one of the default blast output settings. Once you have the blast output, that can be passed to the `slc.pl` script to recover *single-linkage clusters* among loci. This clustering strategy is very simple, but should allow us to identify loci that share regions of high similarity.

```
perl slc.pl <BLAST_OUTPUT>
```

The script will always generate a file called `slc.txt`. I pick one locus from the clusters by selecting the longest assembly (determined across all individuals). The `slc.txt` file can be passed to `retainLongestLocus.pl` to generate a list of loci that *in my opinion* should be removed. I leave it to others to either write a script to clean their data from here or simply move some files around manually, but you can get the list named `shortLoci.txt`.

```
perl retainLongestLocus.pl
```
One limiting assumption here is that you **alignments in fasta format have to be in a folder named fasta** and they **must have the extention .fasta**. I also assume that the fasta folder is in the same directory where you run the script. The script can be edited if you have a different file extention or different location of alignments, but you can always copy then delete.

 

### Reference
Tiley GP, Crowl AA, Almary TO, Luke WR, Solofondranohatra CL, Besnard G, Lehmann CE, Yoder AD, Vorontsova MS. 2023. Genetic variation in Loudetia simplex supports the presence of ancient grasslands in Madagascar. bioRxiv. https://doi.org/10.1101/2023.04.07.536094

