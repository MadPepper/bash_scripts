#!/bin/bash

##########
# blackpills downloader
# require: awk, ffmpeg
##########

# setting
## height_bitrate
## 480_1500
## 720_2000
## 720_3000
## 720_4000
## 480_1000
## 380_700
## 1080_5000
## 240_400
## 1080_6000
## 240_250
## 1440_12000
quality="1440_12000"
downloadsubtitle=true #download subtitle files into /tmp/blackpills/sub
downloadaudio=false #download audio files into /tmp/blackpills/aud
downloadvideo=false #donwload video files into /tmp/blackpills/vid

# setup download
## download top m3u8
mkdir /tmp/blackpills
cd /tmp/blackpills
curl -o "top.m3u8" $1

## download source m3u8s
m3u8list=`cat "top.m3u8" | awk -F '\#flag\#' '/https/{gsub(/https/, "\#flag\#\-O\ https"); gsub(/\"/, ""); gsub(/\?access_token\=/, ""); print $2}'`
#echo $m3u8list
mkdir m3u8
cd m3u8
curl $m3u8list
cd ..

## generate download list
filelist=`ls m3u8/*.m3u8`
#echo $filelist
downlist=`cat $filelist | awk -F '\#flag\#' -v 'OFS=\n' '/https/{gsub(/https/, "\#flag\#\-O\ https"); gsub(/\"/, ""); gsub(/\?access_token\=/, ""); print $2}'`
#echo "$downlist"
sublist=`echo "$downlist" | awk '/sub/{print}'`
audlist=`echo "$downlist" | awk '/aud/{print}'`
vidlist=`echo "$downlist" | awk '/'$vidqua'/{print}'`
#echo "$sublist"
#echo "$audlist"
#echo "$vidlist"


# download audio, video, subtitle files
## subtitle
if [ $downloadsubtitle == true ]; then
    mkdir sub
    cd sub
    curl $sublist
    cd ..
fi

## audio
if [ $downloadaudio == true ]; then
    mkdir aud
    cd aud
    curl $audlist
    cd ..
fi

## video
if [ $downloadvideo == true ]; then
    mkdir vid
    cd vid
    curl $vidlist
    cd ..
fi

## generate file list
subfiles=`ls -d sub/*`
audfiles=`ls -d aud/*`
vidfiles=`ls -d vid/*`
#echo "$subfiles"


# ffmpeg process
## create parameter
if [ $downloadsubtitle == true ]; then
    subinput=`echo "$subfiles" | awk '{gsub(/sub\//, "\ -i sub\/"); print}'`
    submap=`echo "$subinput" | awk -F "\-i" '{print "\ \-map\ " NR "\:0\:0\:" NR+1}'`
fi

## create m3u8 file for download
downloadm3u8=`cat top.m3u8`

if [ $quality != "480_1500"   ]; then downloadm3u8=`echo "$downloadm3u8" | awk '!/1500.*480|480\_1500\_/{print}'`;    fi
if [ $quality != "720_2000"   ]; then downloadm3u8=`echo "$downloadm3u8" | awk '!/2000.*720|720\_2000\_/{print}'`;    fi
if [ $quality != "720_3000"   ]; then downloadm3u8=`echo "$downloadm3u8" | awk '!/3000.*720|720\_3000\_/{print}'`;    fi
if [ $quality != "720_4000"   ]; then downloadm3u8=`echo "$downloadm3u8" | awk '!/4000.*720|720\_4000\_/{print}'`;    fi
if [ $quality != "480_1000"   ]; then downloadm3u8=`echo "$downloadm3u8" | awk '!/1000.*480|480\_1000\_/{print}'`;    fi
if [ $quality != "380_700"    ]; then downloadm3u8=`echo "$downloadm3u8" | awk '!/700.*380|380\_700\_/{print}'`;      fi
if [ $quality != "1080_5000"  ]; then downloadm3u8=`echo "$downloadm3u8" | awk '!/5000.*1080|1080\_5000\_/{print}'`;  fi
if [ $quality != "240_400"    ]; then downloadm3u8=`echo "$downloadm3u8" | awk '!/400.*240|240\_400\_/{print}'`;      fi
if [ $quality != "1080_6000"  ]; then downloadm3u8=`echo "$downloadm3u8" | awk '!/6000.*1080|1080\_6000\_/{print}'`;  fi
if [ $quality != "240_450"    ]; then downloadm3u8=`echo "$downloadm3u8" | awk '!/250.*240|240\_250\_/{print}'`;      fi 
if [ $quality != "1440_12000" ]; then downloadm3u8=`echo "$downloadm3u8" | awk '!/12000.*1440|1440\_12000_/{print}'`; fi

echo "$downloadm3u8" > download.m3u8
#cat download.m3u8

## execute ffmpeg
ffmpeg -protocol_whitelist file,http,https,tcp,tls,crypto -i download.m3u8 $subinput -map 0:0:0:0 -map 0:1:0:1 $submap -c:v copy -c:a copy -c:s mov_text ~/Downloads/$2

