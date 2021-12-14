

cat ./compare/compare* > compare.tar.gz && tar -xzvf compare.tar.gz;
cat ./profile/profile* > profile.tar.gz && tar -xvzf profile.tar.gz;

sudo mv facecompare /usr/bin
sudo mv faceprofile /usr/bin

rm profile.tar.gz;
rm compare.tar.gz;
