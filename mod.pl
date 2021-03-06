#!"C:\perl\bin\perl.exe"

use strict;
use Switch;
use File::Copy;

my $command = "pdftk ";
my %finalpages;
my $ARGC = @ARGV;
my $num = 0;

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
 
sub get_direction {
    my $d = shift;
    switch ($d) {
       case 'R' { return "right" }
       case 'L' { return "left" }
       case 'S' { return "south" }
       case 'N' { return "north" }
       else {return }
    }
}

sub update_finals {

    my $page = shift;
    if ( $page =~ /(\d+)(-\d+|-end)(\w?)/ ) {
        my $begin = $1;
        my $end = $2;
        my $altern = $3;
        if ( defined($altern) && ($altern eq "S" || $altern eq "R" || $altern eq "L" || $altern eq "D") ) {
            if ( $end == "-end" ) {
                $end = $num
            } else {
                $end =~ s/-//;
            }
            for (my $var = $begin; $var <= $end; $var++) {
                if ( $altern eq "D" ) {
                    $finalpages{$var} = "-1";
                }
                else {
                    $finalpages{$var} = get_direction($altern);
                }
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
            $finalpages{$num} = get_direction($altern);
        }
        elsif (  $altern eq "D" ) {
            $finalpages{$num} = "-1";
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
    my $finalfile = "finalfile.pdf";

    if ( $doc == "-i" ) {
       $doc = shift (@pages); 
       $finalfile = $doc;
    }
    $command = "$command \"$doc\" cat";
    move($doc, "temp.pdf");
    $num = num_pages("temp.pdf");
    move("temp.pdf", $doc);

    for ( my $i = 1; $i < $num+1; $i++ ) {
        $finalpages{$i} = "";
    }
    
    while (<@pages>) {
        my $current = $_;
        update_finals($current);
    }

    for ( my $i = 1; $i < $num+1; $i++ ) {
        my $next_page = "";
        if ( $finalpages{$i} ne "-1" ) {
            $next_page = "$i$finalpages{$i}";
        }
        $command = "$command $next_page";
    }

    $command = "$command output temp.pdf";

    print "Command:\n$command\n";
    `$command`;
    move("temp.pdf", $finalfile);   
}
