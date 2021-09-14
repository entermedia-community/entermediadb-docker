

cat ./compare/compare* > compare.tar.gz && tar -xzvf compare.tar.gz;
cat ./profile/profile* > profile.tar.gz && tar -xvzf profile.tar.gz;

rm profile.tar.gz;
rm compare.tar.gz;
