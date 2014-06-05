#!/bin/bash -h

#===========================================================================
# mail_script
#			Author:kannyo
#===========================================================================

# --------------------------------------------------------------------------
# format
# --------------------------------------------------------------------------

# ��ƃf�B���N�g��
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

# �{���Ɏg���t�@�C����
PS_FILE=$test_maildir/ps_$target_date.txt
# ���[���{���̈ꎞ�t�@�C��
tmp=$test_maildir/MAIL_$target_date.tmp

# --------------------------------------------------------------------------
# mail format
# --------------------------------------------------------------------------

# ���M��A�h���X
address="user@hoge.co.jp"
ccaddress="user2@hoge.co.jp"

# ���M���A�h���X���w�肷��ꍇ
#fromaddress="***"

# ����
subject="mail_test_$target_date"
subject=`echo $subject | nkf -j`

# --------------------------------------------------------------------------
# main routine
# --------------------------------------------------------------------------

# �L�^�p�̎��Ԃ�ۑ�
savetime=`date +%Y/%m/%d_%H:%M:%S`

# �v���Z�X�̏�Ԃ�ϐ��ɕۑ�

psbody=`ps -aux | sed -e "s/$/\r\n/g"`

# �t�@�C���ɂ��c���Ă���ǂݎ��ꍇ�͉��L�̗l��

# ps -aux > $PS_FILE
# psbody=`cat $PS_FILE | sed 's/$/\r\n/g'`

# ���C���p
line="--------------------------------------------------------------------"

# --------------------------------------------------------------------------
# mail body
# --------------------------------------------------------------------------

# ���[���{���́AMIME�^�C�v�ɂ�����echo���g���ĒǋL���Ă����B
# 	�p�r�ɉ����ĕ����R�[�h��ύX��������e������������B
# 	�܂��A�{������if���Ȃǂ�p���āA�G���[�����������Ƀ��[�����e��
# 	�ύX���铙�̑Ώ����ł���B

# --------------------------------------------------------------------------
# ��������

# �w�b�_����
echo 'Subject: '$subject > $tmp
echo 'To: '$address >> $tmp
echo 'Cc: '$ccaddress >> $tmp
#echo 'From: '$fromaddress >> $tmp
echo 'Mime-Version: 1.0' >> $tmp
echo 'Content-Type: text/plain; charset=iso-2022-jp' >> $tmp
echo 'Content-Transfer-Encoding: 7bit' >> $tmp
echo '' >> $tmp

# �{��
echo '==TEST_MAIL==' >> $tmp
echo 'TODAY_TIME : '`echo $savetime | nkf -s` >> $tmp
echo '' >> $tmp
echo $line >> $tmp
echo '' >> $tmp
echo -e "$psbody" >> $tmp
echo '' >> $tmp
echo $line >> $tmp
echo '' >> $tmp

# �����܂�
# --------------------------------------------------------------------------

# ���[�����M
# 	sendmail�ɐ���̃��[���{���̈ꎞ�t�@�C���𑗂�
/usr/sbin/sendmail -t < $tmp

# ���[���{���̈ꎞ�t�@�C�����폜
rm -f $tmp

