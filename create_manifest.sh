ls -d -1 $PWD/* > list
#ls -d -1 $PWD/* >> list
sed 's/$/,forward/;n' < list > list.new
sed '0~2 s/$/,reverse/g' < list.new > list

filename='list'
while read -r line
do
        i=16S
        id=$(cut -c 14-15 <<< "$line")
        echo "${i}_${id},$line"
done <$filename > new.manifest

filename='new.manifest'
echo "sample-id,absolute-filepath,direction" > manifest
while read -r line
do
	echo $line
done<$filename >> manifest

rm list
rm list.new
rm new.manifest
