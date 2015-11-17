#!/bin/bash
#PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DES=~/SourceCode/qualcomm/8960
SRC=~/SourceCode
DATE=$(date +%m%d%H%M%S)
CDATE=$(date +%Y_%m%d_%H%M%S)
DESFILE=status_"$DATE".log

find $DES -type d -mmin -780 | grep -v '^.*/.git/.*' | grep  '^.*/.git$' > ~/$DESFILE

if [ ! -d $SRC/Daily_build ]; then
	mkdir $SRC/Daily_build
fi
if [ ! -d $SRC/Daily_build/8960 ]; then
	mkdir $SRC/Daily_build/8960
fi

DB="$SRC"/Daily_build/8960
if [ -e ~/$DESFILE ] && [ -s ~/$DESFILE ];then
	cd $DES
	BRANCH=$(git branch | grep '^*' | cut -d ' ' -f 2)
 
	git status | grep '^#.*modified:' | sed 's/^#.*modified: / git add/g' > add.sh
	git status | grep '^#.*deleted:' | sed 's/^#.*deleted: / git rm/g' >> add.sh
	chmod 777 -R add.sh
	`./add.sh`
	git commit -m "Daily commit "$CDATE" "	
	CMNUM=$(git log | grep '^commit' | head -n 1 | cut -d ' ' -f 2 | cut -c 1-7)
	rm -rf out/
	$DES/wade.sh n;$DES/wade.sh otapackage;	
	mkdir $DB/8960_"$DATE"_"$BRANCH"_"$CMNUM" 
	echo yes | ~/bin/cp_IQ8_img out/debug/target/product/msm8960 $DB/8961_"$DATE"_"$BRANCH"_"$CMNUM"
	rm -rf ~/$DESFILE ./add.sh
else    
        echo "No Changes, Daily Build PASS"
	echo "No Changes, Daily Build PASS" > "$DB"/"$CDATE"_PASS.log
	rm -rf ~/"$DESFILE"
fi
