depth=0
getFolders () {
        ./bin/gamadv-xtd3/gam user $myUser print filelist select $1 showownedby any fields name,id showmimetype gfolder depth 0 > $1.csv
        if [[ $(wc -l <$1.csv) -ge 2 ]]
        then
                echo Der er subfolders
                echo From folder $1
                echo To folder $2
                ./bin/gamadv-xtd3/gam user $myUser print filelist select $1 showownedby any fields name,id showmimetype not gfolder depth 0 |./bin/gamadv-xtd3/gam csv - gam user $myUser update drivefile id ~id >

                while IFS="," read -r owner id name 
                do
                        echo $id
                        echo $name
                        ./bin/gamadv-xtd3/gam user bvr@brovstskole.dk create drivefile drivefilename "$name" mimetype gfolder parentid $2 noduplicate > $id.out 2> $id.fail 
                        #echo `cat $id.out|cut -d "(" -f2 | cut -d ")" -f1` 
                        #echo Newsubfolder: $newSubfolder 
                        if [ -s $id.out ]; then
                                #The subfolder was created.
                                getFolders $id `cat $id.out|cut -d "(" -f2 | cut -d ")" -f1`
                        else
                                #The subfolder allready exists
                                getFolders $id `cat $id.fail|rev|cut -d " " -f1 -|rev`
                        fi
                done < <(tail -n +2 $1.csv)
        else
                echo Der er ingen subfolders
                echo From folder $1
                echo To folder $2
                ./bin/gamadv-xtd3/gam user $myUser print filelist select $1 showownedby any fields name,id showmimetype not gfolder depth 0 |./bin/gamadv-xtd3/gam csv - gam user $myUser update drivefile id ~id >

        fi
}

getFolders $fromFolder $toFolder
