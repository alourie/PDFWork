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

    my $page = shift;
    if ( $page =~ /(\d+)-(\d+)(\w?)/ ) {
        my $begin = $1;
        my $end = $2;
        my $altern = $3;
        if ( defined($altern) && ($altern eq "S" || $altern eq "R" || $altern eq "L") ) {
            for (my $var = $begin; $var <= $end; $var++) {
                $finalpages{$var} = $altern;
            }
        }
        else {
            print "ERROR:       $page is incorrect parameter: $altern cannot be used as modifier. Use 'S', 'R' and 'L' only.\n";
            exit 1;
        }
    }
    elsif ( $page =~ /(\d+)(\w?)/) {
        my $num = $1;
        my $altern = $2;
        if ( defined($altern) && ($altern eq "S" || $altern eq "R" || $altern eq "L") ) {
            $finalpages{$num} = $altern;
        }
        else {
            print "ERROR:       $page is incorrect parameter: $altern cannot be used as modifier. Use 'S', 'R' and 'L' only.\n";
            exit 1;
        }

    }
    else {
        print "ERROR:       $page is incorrect parameter: Only use page numbers with modifiers.\n";
        exit 1;
    }

}

sub main {

    my ($doc, @pages) = @ARGV;

    $command = "$command \"$doc\" cat";
    move($doc, "temp.pdf");
    my $num = num_pages("temp.pdf");
    move("temp.pdf", $doc);

    for ( my $i = 1; $i < $num+1; $i++ ) {
        $finalpages{$i} = "";
    }
    
    while (<@pages>) {
        my $current = $_;
        update_finals($current);
    }

    for ( my $i = 1; $i < $num+1; $i++ ) {
        $command = "$command $i$finalpages{$i}";
    }

    $command = "$command output finalfile.pdf";
    unlink("finalfile.pdf");

    print "Command:\n$command\n";
    `$command`;
}
