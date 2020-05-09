#Find all the files modified in the last 16 mins for google
for i in `find /home/google/project -mmin -16 -type f  -name "*.zip" -exec ls {} +`;
do
	cp $i /tmp
done
