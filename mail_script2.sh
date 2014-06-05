#!/bin/bash -h

#===========================================================================
# mail_script(Attached file ver.)
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

# 添付ファイル名
FILENAME=test_$target_date.zip
# 添付ファイルのフルパス
MAIL_FILE=$test_maildir/$FILENAME
# 添付元のファイル名
PS_FILE=$test_maildir/ps_$target_date.txt
# メール本文の一時ファイル
tmp=$test_maildir/MAIL_MULTI_$target_date.tmp

# --------------------------------------------------------------------------
# mail format
# --------------------------------------------------------------------------

# 送信先アドレス
address="user@hoge.co.jp"
# 件名
subject="mail_multi_test_$target_date"
subject=`echo $subject | nkf -j`

# --------------------------------------------------------------------------
# main routine
# --------------------------------------------------------------------------

# 記録用の時間を保存
savetime=`date +%Y/%m/%d_%H:%M:%S`

# 添付ファイルの元としてプロセスの状態をファイルに保存
ps -aux > $PS_FILE

# プロセスを保存したファイルをzipファイルに圧縮
zip -j "$PS_FILE".tmp $PS_FILE
# パスワードを設定したい場合は下記の様に記述
# PASSの部分がパスワードになる。
#zip -j -P PASS -e "$PS_FILE".tmp $PS_FILE

# MIMEメール用にbase64形式でエンコーディング
#	そのままだと不要なヘッダ部分が先頭に一行あるので、
#	標準出力からsedに渡して最初の一行を削る。
uuencode -m "$PS_FILE".tmp /dev/stdout | sed -e '1d' > $MAIL_FILE
rm -f "$PS_FILE".tmp

# バウンダリー文字(区切り文字)用のユニーク文字列の作成
bound=SAMPLE${RANDOM}

# --------------------------------------------------------------------------
# mail body
# --------------------------------------------------------------------------

# メール本文は、MIMEタイプにそってechoを使って追記していく。
# 	用途に応じて文字コードを変更したり、添付ファイルが複数あるなら
# 	バウンダリー文字で区切って、添付部分を繰り返すなどの応用ができる。
# 	また、本文中にif文などを用いて、エラーがあった時にメール内容を
# 	変更する等の対処もできる。

# --------------------------------------------------------------------------
# ここから

# ヘッダ部分
echo 'Subject: '$subject > $tmp
echo 'To: '$address >> $tmp
echo 'Mime-Version: 1.0' >> $tmp
echo 'Content-Type: Multipart/Mixed; boundary='$bound >> $tmp
echo 'Content-Transfer-Encoding: 7bit' >> $tmp
echo '' >> $tmp

# バウンダリー文字(区切り文字)で区切る
echo '--'$bound >> $tmp

# 本文ヘッダ
echo 'Content-Type: text/plain; charset=iso-2022-jp' >> $tmp
echo 'Content-Transfer-Encoding: 7bit' >> $tmp
echo '' >> $tmp
# 本文
echo '==TEST_MAIL==' >> $tmp
echo 'TODAY_TIME : '`echo $savetime | nkf -s` >> $tmp
echo '' >> $tmp

# バウンダリー文字(区切り文字)で区切る
echo '--'$bound >> $tmp

# ファイルを添付する為のヘッダ
echo 'Content-Type: application/zip; name='$FILENAME >> $tmp
echo 'Content-Transfer-Encoding: base64' >> $tmp
echo 'Content-Disposition: attachment; filename='$FILENAME >> $tmp
echo '' >> $tmp
# ファイルを添付
cat $MAIL_FILE >> $tmp
echo '' >> $tmp

# バウンダリー文字(区切り文字)で区切る
echo '--'$bound >> $tmp

# ここまで
# --------------------------------------------------------------------------

# メール送信
# 	sendmailに先程のメール本文の一時ファイルを送る
/usr/sbin/sendmail -t < $tmp

# メール本文の一時ファイルを削除
rm -f $tmp

