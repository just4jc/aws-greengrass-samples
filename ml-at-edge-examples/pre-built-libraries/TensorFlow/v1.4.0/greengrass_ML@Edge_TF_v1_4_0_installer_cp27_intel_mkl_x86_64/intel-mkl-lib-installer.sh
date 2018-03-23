set -e

mkdir ./tmp
sudo apt-get install -y wget
wget --quiet --no-check-certificate -P ./tmp/intel/  https://github.com/01org/mkl-dnn/releases/download/v0.7/mklml_lnx_2018.0.20170425.tgz
cd ./tmp/intel
tar xzvf mklml_lnx_2018.0.20170425.tgz
cd mklml_lnx_2018.0.20170425
sudo cp -r lib/* /usr/lib/
cd ../..
rm -rf intel
sudo apt-get install -y python-numpy python-scipy python-opencv

cd ../
rm -rf tmp
set +e
