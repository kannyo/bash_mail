#!/bin/bash -h

#===========================================================================
# mail_script(Attached file ver.)
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

# �Y�t�t�@�C����
FILENAME=test_$target_date.zip
# �Y�t�t�@�C���̃t���p�X
MAIL_FILE=$test_maildir/$FILENAME
# �Y�t���̃t�@�C����
PS_FILE=$test_maildir/ps_$target_date.txt
# ���[���{���̈ꎞ�t�@�C��
tmp=$test_maildir/MAIL_MULTI_$target_date.tmp

# --------------------------------------------------------------------------
# mail format
# --------------------------------------------------------------------------

# ���M��A�h���X
address="user@hoge.co.jp"
# ����
subject="mail_multi_test_$target_date"
subject=`echo $subject | nkf -j`

# --------------------------------------------------------------------------
# main routine
# --------------------------------------------------------------------------

# �L�^�p�̎��Ԃ�ۑ�
savetime=`date +%Y/%m/%d_%H:%M:%S`

# �Y�t�t�@�C���̌��Ƃ��ăv���Z�X�̏�Ԃ��t�@�C���ɕۑ�
ps -aux > $PS_FILE

# �v���Z�X��ۑ������t�@�C����zip�t�@�C���Ɉ��k
zip -j "$PS_FILE".tmp $PS_FILE
# �p�X���[�h��ݒ肵�����ꍇ�͉��L�̗l�ɋL�q
# PASS�̕������p�X���[�h�ɂȂ�B
#zip -j -P PASS -e "$PS_FILE".tmp $PS_FILE

# MIME���[���p��base64�`���ŃG���R�[�f�B���O
#	���̂܂܂��ƕs�v�ȃw�b�_�������擪�Ɉ�s����̂ŁA
#	�W���o�͂���sed�ɓn���čŏ��̈�s�����B
uuencode -m "$PS_FILE".tmp /dev/stdout | sed -e '1d' > $MAIL_FILE
rm -f "$PS_FILE".tmp

# �o�E���_���[����(��؂蕶��)�p�̃��j�[�N������̍쐬
bound=SAMPLE${RANDOM}

# --------------------------------------------------------------------------
# mail body
# --------------------------------------------------------------------------

# ���[���{���́AMIME�^�C�v�ɂ�����echo���g���ĒǋL���Ă����B
# 	�p�r�ɉ����ĕ����R�[�h��ύX������A�Y�t�t�@�C������������Ȃ�
# 	�o�E���_���[�����ŋ�؂��āA�Y�t�������J��Ԃ��Ȃǂ̉��p���ł���B
# 	�܂��A�{������if���Ȃǂ�p���āA�G���[�����������Ƀ��[�����e��
# 	�ύX���铙�̑Ώ����ł���B

# --------------------------------------------------------------------------
# ��������

# �w�b�_����
echo 'Subject: '$subject > $tmp
echo 'To: '$address >> $tmp
echo 'Mime-Version: 1.0' >> $tmp
echo 'Content-Type: Multipart/Mixed; boundary='$bound >> $tmp
echo 'Content-Transfer-Encoding: 7bit' >> $tmp
echo '' >> $tmp

# �o�E���_���[����(��؂蕶��)�ŋ�؂�
echo '--'$bound >> $tmp

# �{���w�b�_
echo 'Content-Type: text/plain; charset=iso-2022-jp' >> $tmp
echo 'Content-Transfer-Encoding: 7bit' >> $tmp
echo '' >> $tmp
# �{��
echo '==TEST_MAIL==' >> $tmp
echo 'TODAY_TIME : '`echo $savetime | nkf -s` >> $tmp
echo '' >> $tmp

# �o�E���_���[����(��؂蕶��)�ŋ�؂�
echo '--'$bound >> $tmp

# �t�@�C����Y�t����ׂ̃w�b�_
echo 'Content-Type: application/zip; name='$FILENAME >> $tmp
echo 'Content-Transfer-Encoding: base64' >> $tmp
echo 'Content-Disposition: attachment; filename='$FILENAME >> $tmp
echo '' >> $tmp
# �t�@�C����Y�t
cat $MAIL_FILE >> $tmp
echo '' >> $tmp

# �o�E���_���[����(��؂蕶��)�ŋ�؂�
echo '--'$bound >> $tmp

# �����܂�
# --------------------------------------------------------------------------

# ���[�����M
# 	sendmail�ɐ���̃��[���{���̈ꎞ�t�@�C���𑗂�
/usr/sbin/sendmail -t < $tmp

# ���[���{���̈ꎞ�t�@�C�����폜
rm -f $tmp

