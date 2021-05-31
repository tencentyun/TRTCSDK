#! /bin/bash

mkdir -vp QTDemo.app/Contents/MacOS/assets/audio/bgm
mkdir -vp QTDemo.app/Contents/MacOS/assets/video

cp  ./assets/audio/bgm/test_bgm_music_first.mp3 QTDemo.app/Contents/MacOS/assets/audio/bgm/test_bgm_music_first.mp3
cp  ./assets/audio/bgm/test_bgm_music_second.mp3 QTDemo.app/Contents/MacOS/assets/audio/bgm/test_bgm_music_second.mp3
cp  ./assets/audio/bgm/test_bgm_music_third.mp3 QTDemo.app/Contents/MacOS/assets/audio/bgm/test_bgm_music_third.mp3

cp  ./assets/audio/custom_audio.pcm QTDemo.app/Contents/MacOS/assets/audio/custom_audio.pcm

cp  ./assets/video/320x240_video.yuv QTDemo.app/Contents/MacOS/assets/video/320x240_video.yuv
