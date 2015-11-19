#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#Initial Setting
DES=~/SourceCode/work_imobile
SRC=~/SourceCode
CDATE=$(date +%Y_%m%d_%H%M%S)

#Checkinging and Building Daily Build Directory
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

#Destination Git Setting
cd $DES
echo " Get Local Newest Commit Date and Number..."
ORGCMDATE=$(git log -1 --format=%cD | cut -d ' ' -f 2-4)
ORGCMNUM=$(git log --pretty=oneline --abbrev-commit | head -n 1 | cut -d ' ' -f 1)

echo " Checking git branch..."
BRANCH=$(git branch | grep '^*' | cut -d ' ' -f 2)

echo " Updateing git log..."
git pull origin "$BRANCH"

echo " Checking git pull Server last Commit Date and Number... "
NCMDATE=$(git log -1 --format=%cD | cut -d ' ' -f 2-4)        
NCMNUM=$(git log --pretty=oneline --abbrev-commit | head -n 1 | cut -d ' ' -f 1)


#Determine git status and date
if [ "$ORGCMNUM" != "$NCMNUM"  ] ||  [ "$NCMDATE" != "$ORGCMDATE"  ];then
	echo " Commit Change, You have newer Commit..."
	echo " Start Daily Building !!!"
	cd $DES
	"$DES"/makeMtk pandora_g2 n;"$DES"/makeMtk pandora_g2 systemimage;"$DES"/makeMtk pandora_g2 otapackage;	
	echo " Building Finish !!! "
	echo " Copying Image..."
	mkdir "$DB"/IMT8_"$CDATE"_"$BRANCH"_"$NCMNUM" 
	echo yes | ~/bin/cp_MTK_pandora_img out/target/product/pandora_g2 "$DB"/IMT8_"$CDATE"_"$BRANCH"_"$NCMNUM"
	echo "Done !!!"
else 
	echo "Already Commit Today , Daily Build PASS"
	echo "Already Commit Today , Daily Build PASS" > "$DB"/"$CDATE"_PASS.log
fi
