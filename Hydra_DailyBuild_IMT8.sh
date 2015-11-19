#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DES=~/SourceCode/work_imobile
SRC=~/SourceCode
DATE=$(date +%m%d%H%M%S)
CDATE=$(date +%Y_%m%d_%H%M%S)
NDATE=$(date +"%d %b %Y")

cd $DES
CMDATE=$(git log -1 --format=%cD | cut -d ' ' -f 2-4)

#DESFILE=status_"$DATE".log
#find $DES -type d -mmin -780 | grep -v '^.*/.git/.*' | grep  '^.*/.git$' > ~/$DESFILE

echo " Checkinging Daily Build Directory..."
if [ ! -d $SRC/Daily_build ]; then
	echo " Building Daily Build Directory..."
	mkdir  $SRC/Daily_build
fi
if [ ! -d $SRC/Daily_build/IMT8 ]; then
	echo "Building Daily Build IMT8 Directory..."
	mkdir $SRC/Daily_build/IMT8
fi

DB="$SRC"/Daily_build/IMT8
echo " Checkinging .git Status "
if [ "$CMDATE" != "$NDATE" ];then
	echo " Start Daily Commit and Building !!!"
	cd $DES
	BRANCH=$(git branch | grep '^*' | cut -d ' ' -f 2)
	git status | grep '^#.*modified:' | sed 's/^#.*modified: / git add/g' > add.sh
	git status | grep '^#.*deleted:' | sed 's/^#.*deleted: / git rm/g' >> add.sh
	chmod 777 -R add.sh
	`./add.sh`
	git commit -m "Daily commit "$CDATE" "	
	CMNUM=$(git log --pretty=oneline --abbrev-commit | head -n 1 | cut -d ' ' -f 1)
	"$DES"/makeMtk pandora_g2 n;"$DES"/makeMtk pandora_g2 systemimage;"$DES"/makeMtk pandora_g2 otapackage;	
	echo " Building Finish !!! "
	echo " Copying Image..."
	mkdir "$DB"/IMT8_"$DATE"_"$BRANCH"_"$CMNUM" 
	echo yes | ~/bin/cp_MTK_pandora_img out/target/product/pandora_g2 "$DB"/IMT8_"$DATE"_"$BRANCH"_"$CMNUM"
	rm -rf ./add.sh
	echo "Done !!!"
else 
	echo "Already Commit Today , Daily Build PASS"
	echo "Already Commit Today , Daily Build PASS" > "$DB"/"$CDATE"_PASS.log
fi
