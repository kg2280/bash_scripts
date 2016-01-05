#!/bin/bash

if (( $# != 2 ))
then
  echo "You need 2 arguments, source_name_of_vm dest_name_of_vm"
  echo "$0 source_vm dest_vm"
else
  cp -rf AAA_Template_Centos7/ $2
  cd $2
  mv $1-flat.vmdk $2-flat.vmdk
  mv $1.nvram $2.nvram
  mv $1.vmdk $2.vmdk
  mv $1.vmsd $2.vmsd
  mv $1.vmx $2.vmx
  mv $1.vmxf $2.vmxf
  sed -i "s/$1/$2/g" $2.*
  cd ..
fi


