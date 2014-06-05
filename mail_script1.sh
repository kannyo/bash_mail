#!/bin/bash -h

#===========================================================================
# mail_script
#			Author:kannyo
#===========================================================================

# --------------------------------------------------------------------------
# format
# --------------------------------------------------------------------------

# 作業ディレクトリ
mail_dir=/home/user/mail

target_date=`date +%Y%m%d`
target_month=`date -d "$target_date" +%Y-%m`
test_maildir=$mail_dir/$target_month
if [ ! -d $test_maildir ]
then
	mkdir $test_maildir
fi

# chenge mode
chmod 775 $test_maildir

# 本文に使うファイル名
PS_FILE=$test_maildir/ps_$target_date.txt
# メール本文の一時ファイル
tmp=$test_maildir/MAIL_$target_date.tmp

# --------------------------------------------------------------------------
# mail format
# --------------------------------------------------------------------------

# 送信先アドレス
address="user@hoge.co.jp"
ccaddress="user2@hoge.co.jp"

# 送信元アドレスを指定する場合
#fromaddress="***"

# 件名
subject="mail_test_$target_date"
subject=`echo $subject | nkf -j`

# --------------------------------------------------------------------------
# main routine
# --------------------------------------------------------------------------

# 記録用の時間を保存
savetime=`date +%Y/%m/%d_%H:%M:%S`

# プロセスの状態を変数に保存

psbody=`ps -aux | sed -e "s/$/\r\n/g"`

# ファイルにも残してから読み取る場合は下記の様に

# ps -aux > $PS_FILE
# psbody=`cat $PS_FILE | sed 's/$/\r\n/g'`

# ライン用
line="--------------------------------------------------------------------"

# --------------------------------------------------------------------------
# mail body
# --------------------------------------------------------------------------

# メール本文は、MIMEタイプにそってechoを使って追記していく。
# 	用途に応じて文字コードを変更したり内容を書き換える。
# 	また、本文中にif文などを用いて、エラーがあった時にメール内容を
# 	変更する等の対処もできる。

# --------------------------------------------------------------------------
# ここから

# ヘッダ部分
echo 'Subject: '$subject > $tmp
echo 'To: '$address >> $tmp
echo 'Cc: '$ccaddress >> $tmp
#echo 'From: '$fromaddress >> $tmp
echo 'Mime-Version: 1.0' >> $tmp
echo 'Content-Type: text/plain; charset=iso-2022-jp' >> $tmp
echo 'Content-Transfer-Encoding: 7bit' >> $tmp
echo '' >> $tmp

# 本文
echo '==TEST_MAIL==' >> $tmp
echo 'TODAY_TIME : '`echo $savetime | nkf -s` >> $tmp
echo '' >> $tmp
echo $line >> $tmp
echo '' >> $tmp
echo -e "$psbody" >> $tmp
echo '' >> $tmp
echo $line >> $tmp
echo '' >> $tmp

# ここまで
# --------------------------------------------------------------------------

# メール送信
# 	sendmailに先程のメール本文の一時ファイルを送る
/usr/sbin/sendmail -t < $tmp

# メール本文の一時ファイルを削除
rm -f $tmp

