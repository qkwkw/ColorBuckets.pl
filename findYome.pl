#! /usr/bin/perl

####################################################################
# findYome.pl                                                      #
#   To compare images and show similarity score without OpenCV.    #
#   Copyright (c) 2012,2015 Queue Sakura-Shiki(@q_kwkw)            #
#   Released under the MIT license                                 #

# Parameters.

# Haredware resource index. It effects quality of similarity score.
my $resABILITY = 70;

# When similarity score is higher than this value, the script writes
# it on standard out.
my $ALERT_BORDERLINE = 70;

# Reducing infomation volume of color.
my $REDUCING_VOLUME = 2**14;

####################################################################

# Alerting file count.
my $cnt = 0;

# Get image files from current directory.
# which is same to this script's directory.
my $targetFile1 = $ARGV[0];
-f $targetFile1 or die "file not found.";
opendir(HDIR, "./") or die($!);
my @dirent = readdir(HDIR);
foreach ( @dirent ) {
  if( -f $_ && $_ ne "." && $_ ne ".." && /(jpg|png|gif)$/ ) {
    $_ eq $targetFile1 and next;

    # Measure similality score many times with different resolution
    # to make the quality better.
    my $totalScore = 0;
    $totalScore += compare($targetFile1,$_,$resABILITY);
    $totalScore += compare($targetFile1,$_,$resABILITY*2/3);
    $totalScore += compare($targetFile1,$_,$resABILITY*9/5);
    $totalScore = 100*$totalScore/3;

    # If both image files are very similer, alert it.
    if( $ALERT_BORDERLINE < $totalScore ) {
      printf "%05.1f\%,%s\n",$totalScore,$_;
      $cnt ++;
    }
  }
}

# Write a result.
printf "  found %d file(s).\n",$cnt;
printf "  Press enter key to finish :";
<STDIN>; # wait for pressing enter key.

exit();


use Image::Magick;

# compare with resolution
#  arg[0] : comparing target file1.
#  arg[1] : comparing target file2.
#  arg[2] : resolution.
sub compare {

  my $targetFile1 = shift;
  my $image1 = Image::Magick->new;
  $image1->Read($targetFile1);
  $image1->Resize(geometry =>$res."x".$res."!");

  my $targetFile2 = shift;
  my $image2 = Image::Magick->new;
  $image2->Read($targetFile2);
  $image2->Resize(geometry =>$res."x".$res."!");

  my $res = int(shift);
  my $score = 0;

  for( my $x=0 ; $x<$res ; $x++ ) {
    for( my $y=0 ; $y<$res ; $y++ ) {
      my ($r1, $g1, $b1) = split /,/,$image1->Get("pixel[".$x.",".$y."]");
      my ($r2, $g2, $b2) = split /,/,$image2->Get("pixel[".$x.",".$y."]");
      if( int($r1/$REDUCING_VOLUME) == int($r2/$REDUCING_VOLUME) &&
          int($g1/$REDUCING_VOLUME) == int($g2/$REDUCING_VOLUME) &&
          int($b1/$REDUCING_VOLUME) == int($b2/$REDUCING_VOLUME) ) {
        $score++;
      }
    }
  }
  return $score*1.0/($res*$res);
}


1;
