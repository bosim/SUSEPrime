#!/bin/bash

# Script for selecting either nvidia og intel card for NVIDIA optimus laptops
# Please follow instructions given in README

# Public domain by Bo Simonsen <bo@geekworld.dk>

type=$1

xorg_conf="/etc/prime/xorg.conf"
offload="/etc/prime/prime-offload.sh"

function clean_files {
      #cleanup vulkan icd files
      rm -f /usr/share/vulkan/icd.d/nvidia_icd.*.json


      rm -f /etc/X11/xinit/xinitrc.d/prime-offload.sh
      rm -f /etc/X11/xorg.conf.d/90-nvidia.conf   
}

case $type in
  nvidia)
      clean_files 

      gpu_info=`nvidia-xconfig --query-gpu-info`
      nvidia_busid=`echo "$gpu_info" |grep -i "PCI BusID"|sed 's/PCI BusID ://'|sed 's/ //g'`
      libglx_nvidia=`update-alternatives --list libglx.so|grep nvidia-libglx.so`

      update-alternatives --set libglx.so $libglx_nvidia

      ln -s $offload /etc/X11/xinit/xinitrc.d/prime-offload.sh

      cat $xorg_conf | sed 's/PCI:X:X:X/'${nvidia_busid}'/' > /etc/X11/xorg.conf.d/90-nvidia.conf

      sed 's|libGLX_nvidia.so.0|/usr/lib64/libGLX_nvidia.so.0|g' /etc/vulkan/icd.d/nvidia_icd.json > /usr/share/vulkan/icd.d/nvidia_icd.x86_64.json
      sed 's|libGLX_nvidia.so.0|/usr/lib/libGLX_nvidia.so.0|g' /etc/vulkan/icd.d/nvidia_icd.json > /usr/share/vulkan/icd.d/nvidia_icd.i586.json

      echo "Running ldconfig"

      ldconfig
  ;;
  intel)
      clean_files

      libglx_xorg=`update-alternatives --list libglx.so|grep xorg-libglx.so`

      update-alternatives --set libglx.so $libglx_xorg

      echo "Running ldconfig"

      ldconfig
  ;;
  *)
      echo "prime-select nvidia|intel"
      exit
  ;;
esac
