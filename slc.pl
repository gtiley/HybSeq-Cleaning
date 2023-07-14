#!/usr/bin/perl -w
#

$blastinput = $ARGV[0];

%locusList = ();
%locusPairs = ();
%slc = ();

open OUT1,'>',"slc.txt";

open FH1,'<',"$blastinput";
while (<FH1>)
{
	$line = $_;
	chomp $line;
	@temp = ();
	@locus1 = ();
	@locus2 = ();
	@temp = split(/\t/, $line);
	@locus1 = split(/-/,$temp[0]);
	@locus2 = split(/-/,$temp[1]);

	#print "$temp[0]\t$locus1[1]\t$temp[1]\t$locus2[1]\n";

	if (! exists $locusList{$locus1[1]})
	{
		$locusList{$locus1[1]} = 1;
	}
	if (! exists $locusList{$locus2[1]})
        {
                $locusList{$locus2[1]} = 1;
        }
	#if ($locus1[1] ne $locus2[1])
	#{
		if ((! exists $locusPairs{$locus1[1]}{$locus2[1]}) && (! exists $locusPairs{$locus2[1]}{$locus1[1]}))
		{
			$locusPairs{$locus1[1]}{$locus2[1]} = 1;
			$locusPairs{$locus2[1]}{$locus1[1]} = 1;
			print "Intializing pair: $locus1[1]\t$locus2[1]\n";

		}
		elsif ((exists $locusPairs{$locus1[1]}{$locus2[1]}) || (exists $locusPairs{$locus2[1]}{$locus1[1]}))
		{
			$locusPairs{$locus1[1]}{$locus2[1]} = $locusPairs{$locus1[1]}{$locus2[1]} + 1;
			$locusPairs{$locus2[1]}{$locus1[1]} = $locusPairs{$locus2[1]}{$locus1[1]} + 1;
			print "Additional pair -->: $locus1[1]\t$locus2[1]: $locusPairs{$locus1[1]}{$locus2[1]}\n";
		}
	#}
}
close FH1;

$nclusters = 0;
foreach $locus1 (sort keys %locusList)
{
	$npairs = 0;
	if ($locusList{$locus1} == 1)
	{
        	$nclusters++;
#		print "$locus1\t$nclusters\n";
		foreach $locus2 (sort keys %locusList)
		{
			if (exists $locusPairs{$locus1}{$locus2})
			{	
				if ($locusPairs{$locus1}{$locus2} > 0)
                                {
					push @{$slc{$locus1}}, $locus2;
					if ($locus1 ne $locus2)
					{
						$locusList{$locus2} = 0;
					}
					$npairs++;
				}
			}		
		}
	}
	print "$nclusters $locus1 $npairs\n";
}

foreach $locus1 (sort keys %locusList)
{
	if (exists $slc{$locus1}[0] && $locusList{$locus1} == 1)
	{
		if (scalar(@{$slc{$locus1}} > 1))
		{
			print OUT1 "$locus1";
			for $i (1..(scalar(@{$slc{$locus1}}) - 1))
			{
				print OUT1 "\t$slc{$locus1}[$i]"; 
			}
			print OUT1 "\n";
		}
		elsif (scalar(@{$slc{$locus1}} == 1))
		{
			print OUT1 "$locus1\n";
		}
	}
	#else
	#{
	#	print OUT1 "$locus1\n";
	#}
}
close OUT1;

exit;
