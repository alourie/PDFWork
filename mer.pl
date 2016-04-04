#!"C:\perl\bin\perl.exe"


use strict;
use File::Copy;

my $doc1_pattern = "doc1_%04d.pdf";
my $doc2_pattern = "doc2_%04d.pdf";

my $command = "pdftk ";
my $ARGC = @ARGV;

my $first = "first.pdf";
my $second = "second.pdf";

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
 
sub main {

    my $pages1 = 0;
    my $pages2 = 0;
    my $pages = 0;
    my $firstname = "";
    my $secondname = "";


    if ( $ARGC < 2) {
        print "Please enter file name 1, file name 2 as parameters";
        exit 1;
    }
    else {
        
        my $firstname = $ARGV[0];
        my $secondname = $ARGV[1];

        move($firstname, $first);
        move($secondname, $second);
        $pages1 = num_pages($first);
        $pages2 = num_pages($second);
        $pages = 0;

        my $split_command1 = "pdftk $first burst output $doc1_pattern";    
        my $split_command2 = "pdftk $second burst output $doc2_pattern";    
        
        system($split_command1); system($split_command2);
        
        move($first, $firstname);
        move($second, $secondname);

        if ( $pages1 == 0 || $pages2 == 0 ) {
            print "Error finding number of pages!!!\n";
            exit 1;
        }

        if  ( $pages1 > $pages2 ) {
            $pages = $pages2;
        }
        else {
            $pages = $pages1;
        }

        my $maxpages = $pages + 1;
        for (my $var = 1; $var < $maxpages; $var++) {
            my $var2 = $maxpages - $var;
            my ($d1, $d2);
            
            
            if ( $var < 10 ) {
                $d1 = "000$var";
            }
            elsif ( $var > 99 ) {
                $d1 = "0$var";
            }
            else {
                $d1 = "00$var";
            }
            
            if ( $var2 < 10 ) {
                $d2 = "000$var2";
            }
            elsif ( $var2 > 99 ) {
                $d2 = "0$var2";
            }
            else {
                $d2 = "00$var2";
            }
            
            $command = $command . "doc1_$d1.pdf doc2_$d2.pdf ";
        }

    }

    my $time = `time /t`;
    chomp $time;
    my @newtime = split(':', $time);
    $time = "$newtime[0]$newtime[1]";
    my $outfile = "FinalFile_$time\.pdf";

    $command = $command . " output \"$outfile\"";
    print "\n\nCommand:\n $command\n";
    `$command`;

}
