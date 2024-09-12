#!/usr/bin/perl
$USE_MPI{optics} ='mpiexec.hydra -np 32';
# Library headers
my $OPC_HOME = "/lustre/scafellpike/local/HCP098/jkj01/pxp52-jkj01/OPC/Physics-OPC-0.7.10.3";
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
use lib "/lustre/scafellpike/local/HCP098/jkj01/pxp52-jkj01/OPC/Physics-OPC-0.7.10.3/lib";
use Physics::OPC;

$VERBOSE = 0;

my $filename = $ARGV[0]; # opcFieldFile.dfl
my $detune_factor = $ARGV[1]; # detuning factor in the unit of lambda_r (number of wavelngths those are padded)
my $mirror_R1 = $ARGV[2]; # mirror1 reflectivity
my $mirror_R2 = $ARGV[3]; # mirror2 reflectivity

(my $without_extension = $filename) =~ s/\.[^.]+$//; # remove file extension
my $out1 = substr($without_extension, -1); # get the last file character either x or y
my $outfile = 'entrance' . '_' . $out1 . '.dfl' ;

# initialised field from file name in OPC
$field = field file => $filename;

# Resenant cavity length is 14.9896229 m from f_rep = 10MHz
# cavity cofiguration from left-to-right 
#   M2_(---L3-->-||||Lu||||||----L1--->---)_M1
# hole_|<-------<------Lcav---------<-----|
my $Lambda_res = get_param $field 'lambda'; # resonant wavelength
my $detune_cav = -$detune_factor*$Lambda_res; # cavity detuning length

my $Lcav_res = 5.35344; # resonant cavity length
my $L1 = 1.62131; #L1 first path
my $Lcav = $Lcav_res + 0.5*$detune_cav; # L2 second path
my $L3 = 2.13213 + 0.5*$detune_cav; # L3 third path

my $r_1 = 2.6126; # M1 radius of curvature
my $r_2 = 3.0907; # M2 radius of curvature

$optics = optics "
# 1st propagation to mirror_1
  diaphragm r=0.017
  fresnel z=$L1 M=2.5

  diaphragm r=0.017
  mirror r=$r_1 R=$mirror_R1
  dump var = mirror1

# 2nd propagation from mirror_1 to mirror_2  
  fresnel z=$Lcav M=1

  diaphragm r=0.017
  hole r=0.0013(
  dump var=output
  fresnel z = 0.6
  dump var=far M=0.4)
  mirror r=$r_2 R=$mirror_R2
  dump var = mirror2

# 3rd propagation from mirror_2 to undulator entrance
  fresnel z=$L3 M=0.4";

run $optics;
my $M1 = 'M1' . '_' . $out1 . '.dfl' ;
move $mirror1 => "$M1";

my $holeout = 'hole'. '_' . $out1 . '.dfl' ;
move $output => "$holeout";

my $farout = 'far'. '_' . $out1 . '.dfl' ;
move $far => "$farout";

my $M2 = 'M2' . '_' . $out1 . '.dfl' ;
move $mirror2 => "$M2";

zshift $field $z_shift;
move $field => "$outfile";


# remove temporary files
unlink glob "opc_wis* var1* var2*";
