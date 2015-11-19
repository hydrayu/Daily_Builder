#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#Initial Setting
DES=~/SourceCode/qualcomm/8960
SRC=~/SourceCode
CDATE=$(date +%Y_%m%d_%H%M%S)

#Checkinging and Building Daily Build Directory
echo " Checkinging Daily Build Directory..."
if [ ! -d $SRC/Daily_build ]; then
	echo " Building Daily Build Directory..."
	mkdir $SRC/Daily_build
fi
if [ ! -d $SRC/Daily_build/8960 ]; then
	echo " Building Daily Build 8960 Directory..."
	mkdir $SRC/Daily_build/8960
fi
DB="$SRC"/Daily_build/8960

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
	rm -rf out/
	$DES/wade.sh n;$DES/wade.sh otapackage;	
	echo " Building Finish !!! "
	echo " Copying Image..."
	mkdir $DB/8960_"$CDATE"_"$BRANCH"_"$NCMNUM" 
	echo yes | ~/bin/cp_IQ8_img out/debug/target/product/msm8960 $DB/8960_"$CDATE"_"$BRANCH"_"$NCMNUM"
	echo "Done !!!"
else    
        echo "Already Commit Today , Daily Build PASS"
	echo "Already Commit Today , Daily Build PASS" > "$DB"/"$CDATE"_PASS.log

fi
