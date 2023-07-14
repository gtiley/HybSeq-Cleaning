#!/usr/bin/perl -w
#
#Assume that alignments have the extension .fasta and are in a folder "fasta" that exists in the same folder where the script is launched


$slcFile = "slc.txt";

%alignmentLengths = ();
@alignments = glob("fasta/*.fasta");
foreach $aln (@alignments)
{
	if ($aln =~ m/fasta\/(\S+)\.fasta/)
	{
		$prefix = $1;
		$alnlen = 0;
		open FH1,'<',"$aln";
		while (<FH1>)
		{
			if (/^>\S+/)
			{
				#skip
			}
			elsif (/(\S+)/)
			{
				$seq = $1;
				if (length($seq) > $alnlen)
				{
					$alnlen = length($seq);
					$alignmentLengths{$prefix} = $alnlen;
					print "$prefix\t$alnlen\t$alignmentLengths{$prefix}\n";
				}
			}
		}
		close FH1;
	}
}


open FH1,'<',"slc.txt";
open OUT1,'>',"shortLoci.txt";
while (<FH1>)
{
	$line = $_;
	chomp $line;
	@locusCluster = ();
	@locusCluster = split(/\t/,$line);
	$maxLength = 0;
	$bestBoi = "NA";
	print "$line\n";
	foreach $locus (@locusCluster)
	{
		$locus = "$locus" . "_supercontig";
		print "$locus\n";
		if (exists $alignmentLengths{$locus})
		{
			if ($alignmentLengths{$locus} > $maxLength)
			{
				$maxLength = $alignmentLengths{$locus};
				$bestBoi = $locus;	
			}
		}
		elsif (! exists $alignmentLengths{$locus})
		{
			print "--> $locus not present among alignments!\n";
		}
	}
	foreach $locus (@locusCluster)
        {
                if ($locus ne $bestBoi)
                {
                        print OUT1 "$locus\n";
                }
        }
}
close OUT1;
close FH1;
exit;
