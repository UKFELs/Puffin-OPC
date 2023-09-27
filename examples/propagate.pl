#!/usr/bin/perl
# Library headers
$USE_MPI{optics} ='mpirun -np 4';
my $libdir;
BEGIN {
 #find path to Physics-OPC-x.x.x/lib directory containing the OPC perl modules.
 use Cwd 'cwd';                      # to retrieve current working dir
 use File::Spec qw/splitdir catdir/; # to split or combine directory names
 #first check if environment variable is set
 $libdir = File::Spec->catdir($ENV{OPC_HOME}, 'lib');

 unless (-d $libdir) {
   #not found, now check in path to directory from which script is run 
   my @mydirs =  File::Spec->splitdir( Cwd->cwd() );
   while (@mydirs) {
     $libdir = File::Spec->catdir (@mydirs, $OPC_VERSION, 'lib');
     last if -d $libdir;
     pop @mydirs;
   }
 }
}

use lib "$libdir";
use Physics::OPC;
# Check if a filename was provided
unless (@ARGV) {
    die "Usage: $0 <filename>\n";
}

$VERBOSE = 0;

my $filename = $ARGV[0];
# Extract the "_x" or "_y" part from the filename
my ($suffix) = $filename =~ /(_[^_]+)\.\w+$/;

unless ($suffix) {
    die "The filename does not have the expected format.\n";
}

$field = field file => $filename;
    
$optics = optics "
        fresnel z=11.309
    
        hole r=0.0005 (
          dump var=output_hole
        )
        diaphragm r=0.002 
        mirror r=17.50314102 R=70%
        dump var = mirror1

        fresnel z=34.618

        diaphragm r=0.002
        mirror r=17.50314102 R=70%
        dump var = mirror2

        fresnel z=11.309";

run $optics;
move $output_hole => "outhole$suffix.dfl";
move $mirror1 => "M1$suffix.dfl";
move $mirror2 => "M2$suffix.dfl";
move $field => "entrance$suffix.dfl";

# remove temporary files
unlink glob "opc_wis* var1* var2*";
