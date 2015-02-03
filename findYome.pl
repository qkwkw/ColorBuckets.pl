#! /usr/bin/perl

my $CAPABILITY = 70;
my $ALERT_RANGE = 70;

use Image::Magick;
my $targetFile = $ARGV[0];

-f $targetFile or die "file not found.";

opendir(HDIR, "./") or die($!);

my @dirent = readdir(HDIR);
my $cnt = 0;
foreach ( @dirent ) {
  if( -f $_ && $_ ne "." && $_ ne ".." && /(jpg|png|gif)$/ ) {
    if( $_ eq $targetFile ) { next; }
    my $totalScore = 0;
    $totalScore += compareByScale($targetFile,$_,$CAPABILITY);
    $totalScore += compareByScale($targetFile,$_,$CAPABILITY*2/3);
    $totalScore += compareByScale($targetFile,$_,$CAPABILITY*9/5);
    $totalScore = 100*$totalScore/3;
    if( $totalScore > $ALERT_RANGE ) {
      printf "%05.1f\%,%s\n",$totalScore,$_;
      $cnt ++;
    }
  }
}
printf "  found %d file(s).\n",$cnt;
printf "  Press enter key to finish :";
<STDIN>;

exit();

sub compareByScale {

  my $targetFile = shift;
  my $listFile = shift;
  my $target = Image::Magick->new;
  my $image = Image::Magick->new;
  my $cap = int(shift);
  my $score = 0;


  $target->Read($targetFile);
  $image->Read($listFile);
  $target->Resize(geometry => $cap."x".$cap."!");
  $image->Resize(geometry =>$cap."x".$cap."!");
  for( my $x=0 ; $x<$cap ; $x++ ) {
    for( my $y=0 ; $y<$cap ; $y++ ) {
      my ($r1, $g1, $b1) = split /,/,$image->Get("pixel[".$x.",".$y."]");
      my ($r2, $g2, $b2) = split /,/,$target->Get("pixel[".$x.",".$y."]");
      if( int($r1/16384) == int($r2/16384) &&
          int($g1/16384) == int($g2/16384) &&
          int($b1/16384) == int($b2/16384) ) {
          $score++;
        }
     }
  }
  return $score*1.0/($cap*$cap);
}


1;
