echo "Id of folder to copy FROM: "
read fromFolder
echo "Id of folder to copy TO: "
read toFolder

echo Trying to move subfolders from $fromFolder to $toFolder

depth=0
getFolders () {
	./bin/gamadv-xtd3/gam user bend0006@brovstskole.dk print filelist select $1 showownedby any fields name,id showmimetype gfolder depth 0 > $1.csv
	if [[ $(wc -l <$1.csv) -ge 2 ]]
	then
        	echo Der er subfolders
		./bin/gamadv-xtd3/gam user bend0006@brovstskole.dk print filelist select $1 showownedby any fields name,id showmimetype not gfolder depth 0 |./bin/gamadv-xtd3/gam csv - gam user bvr@brovstskole.dk update drivefile id ~id parentid $2

		while IFS="," read -r owner id name 
		do
			echo $id
			echo $name
			./bin/gamadv-xtd3/gam user bvr@brovstskole.dk create drivefile drivefilename "$name" mimetype gfolder parentid $2 noduplicate > $id.out
			#echo `cat $id.out|cut -d "(" -f2 | cut -d ")" -f1` 
			#echo Newsubfolder: $newSubfolder 
			getFolders $id `cat $id.out|cut -d "(" -f2 | cut -d ")" -f1`
		done < <(tail -n +2 $1.csv)
	else
        	echo Der er ingen subfolders
		./bin/gamadv-xtd3/gam user bend0006@brovstskole.dk print filelist select $1 showownedby any fields name,id showmimetype not gfolder depth 0 | ./bin/gamadv-xtd3/gam csv - gam user bvr@brovstskole.dk update drivefile id ~id parentid $2

	fi
}

getFolders $fromFolder $toFolder
