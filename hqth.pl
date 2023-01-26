#
# Query the HAMQTH Database server for a callsign
#
# from an idea by Steve Franke K9AN and information from Angel EA7WA
#
# Copyright (c) 2001 Dirk Koopman G1TLH
#
# modified on 5/13/2009 Ricardo Suarez LU9DA to work with the hamqth web page.
#
# need for WWW:Mechanize ! download it from CPAN
#
# working under test on lu9da-6 cluster ( lu9da.no-ip.org 9000)
#

use WWW::Mechanize;


my ($self, $line) = @_;
my @list = split /\s+/, $line;		      # generate a list of callsigns
my $l;
my $call = $self->call;
my @out;
my $url;
my $page;
my $count;
my $linea;
my $indx;
my $session_id;

return (1, $self->msg('e24')) unless $Internet::allow;
return (1, "SHOW/HQTH <callsign>, e.g. SH/HQTH lu9da") unless @list;

$url = "http://www.hamqth.com/xml.php?u=YOURCALL&p=YOURPASS";

my $mechanize = WWW::Mechanize->new(autocheck => 1);
$mechanize->agent_alias('Windows Mozilla');


#----------------------

$mechanize->get($url);

$page = $mechanize->content;

my @tabla = split('\n', $page);


foreach $linea (@tabla) {

	if ($linea =~ m/<session_id>/) {

	    $linea =~ s/<session_id>//;

	    $linea =~ s/<\/session_id>//;

	    $session_id = $linea;

	    $session_id =~ s/^\^s+//;

	    }

}
#-----------


$session_id =~ s/^\s+//;


$url = "http://www.hamqth.com/xml.php?id=$session_id&callsign=@list&prg=hqth.pl";

$mechanize->get($url);

$page = $mechanize->content;

my @tabla = split('\n', $page);

push @out," ";

push @out,"HAMQTH search for @list:";

push @out," ";

foreach $linea (@tabla) {

	if ($linea =~ m/<HamQTH/) {
	    $linea="";
	    }
		
	
		$linea =~ s/<\?xml version=\"1.0\"\?>//;
		$linea =~ s/<\/HamQTH>//;
		$linea =~ s/<search>//;
		$linea =~ s/<\/search>//;
		$linea =~ s/<session>//;
		$linea =~ s/<\/session>//;
#
		my $pos=rindex($linea,"</");
		$linea=substr($linea,0,$pos);

		$linea =~ s/<//;
		$linea =~ s/>/ : /;
		
		push @out, $linea;

		}




return (1, @out);



