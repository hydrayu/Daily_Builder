#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DES=~/SourceCode/MT8382
SRC=~/SourceCode
DATE=$(date +%m%d%H%M%S)
CDATE=$(date +%Y_%m%d_%H%M%S)
DESFILE=status_"$DATE".log

find $DES -type d -mmin -780 | grep -v '^.*/.git/.*' | grep  '^.*/.git$' > ~/$DESFILE

if [ ! -d $SRC/Daily_build ]; then
	mkdir  $SRC/Daily_build
fi
if [ ! -d $SRC/Daily_build/MT8382 ]; then
	mkdir $SRC/Daily_build/MT8382
fi

DB="$SRC"/Daily_build/MT8382

if [ -e ~/$DESFILE ] && [ -s ~/$DESFILE ];then
	cd $DES
	BRANCH=$(git branch | grep '^*' | cut -d ' ' -f 2)
	git checkout mediatek/kernel/trace32/mt82kk_tb_ramdisk.img 
	git status | grep '^#.*modified:' | sed 's/^#.*modified: / git add/g' > add.sh
	git status | grep '^#.*deleted:' | sed 's/^#.*deleted: / git rm/g' >> add.sh
	chmod 777 -R add.sh
	`./add.sh`
	git commit -m "Daily commit "$CDATE" "	
	CMNUM=$(git log | grep '^commit' | head -n 1 | cut -d ' ' -f 2 | cut -c 1-7)
	"$DES"/makeMtk mt82kk_tb n;"$DES"/makeMtk mt82kk_tb systemimage;"$DES"/makeMtk mt82kk_tb otapackage;	
	mkdir "$DB"/MT8382_"$DATE"_"$BRANCH"_"$CMNUM" 
	echo yes | ~/bin/cp_MTK_pandora_img out/target/product/mt82kk_tb "$DB"/MT8382_"$DATE"_"$BRANCH"_"$CMNUM"
	rm -rf ~/"$DESFILE" ./add.sh
else 
	echo "No Changes, Daily Build PASS"
	echo "No Changes, Daily Build PASS" > "$DB"/"$CDATE"_PASS.log
	rm -rf ~/"$DESFILE"
fi
