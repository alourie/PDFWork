#!"C:\perl\bin\perl.exe"

use strict;
use File::Copy;

my $command = "pdftk ";
my %finalpages;
my $ARGC = @ARGV;

main();

sub num_pages {

    my $file = shift;
    my $num = 0;
    my $command = "pdftk $file dump_data";
    my $out = `$command`;
    chomp $out;

    if ( $out =~ /NumberOfPages: (\d+)/ ) {
        $num = $1;
    }

    print "File: $file, pg: $num\n";
    return $num;
}
 
sub update_finals {

}

sub main {

    my ($doc, @pages) = @_;

    move($doc, "temp.pdf");
    my $num = num_pages("temp.pdf");
    move("temp.pdf", $doc);

    my $i = 0;
    for ( $i = 1; $i < $num+1; $i++ ) {
        $finalpages{$i} = "";
    }
    
    while (<@pages>) {
        
        my $current = $_;
        update_finals($current);
    }


    $command = $command . " output \"$outfile\"";
    `$command`;
}
