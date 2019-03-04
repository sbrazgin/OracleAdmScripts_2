#!/bin/bash

######################################
#
# ssh config
#
######################################

source 00_all_vars.sh

if [[ -f $RSA_FILE_NAME ]] || [[ -f $RSA_FILE_NAME.pub ]]; then
	rm ./$RSA_FILE_NAME*;
fi

if [[ -f $DSA_FILE_NAME ]] || [[ -f $DSA_FILE_NAME.pub ]]; then
	rm ./$DSA_FILE_NAME*;
fi

if [ -f $PUB_KEYS_FILE ]; then
	rm ./$PUB_KEYS_FILE
fi

ssh-keygen -q -t rsa -N "" -f $RSA_FILE_NAME
ssh-keygen -q -t dsa -N "" -f $DSA_FILE_NAME

cat ./$RSA_FILE_NAME.pub >> ./$PUB_KEYS_FILE
cat ./$DSA_FILE_NAME.pub >> ./$PUB_KEYS_FILE

mkdir -p ~/$SSH_KEY_DIR

# check old id keys - not remove
if [ -f ~/$SSH_KEY_DIR/$RSA_FILE_NAME ]; then
        mv ~/$SSH_KEY_DIR/$RSA_FILE_NAME ~/$SSH_KEY_DIR/$RSA_FILE_NAME.old;
        mv ~/$SSH_KEY_DIR/$RSA_FILE_NAME.pub ~/$SSH_KEY_DIR/$RSA_FILE_NAME.pub.old;
fi

if [ -f ~/$SSH_KEY_DIR/$DSA_FILE_NAME ]; then
        mv ~/$SSH_KEY_DIR/$DSA_FILE_NAME ~/$SSH_KEY_DIR/$DSA_FILE_NAME.old;
        mv ~/$SSH_KEY_DIR/$DSA_FILE_NAME.pub ~/$SSH_KEY_DIR/$DSA_FILE_NAME.pub.old;
fi

# move created keys public + private
mv ./$RSA_FILE_NAME ~/$SSH_KEY_DIR/$RSA_FILE_NAME;
mv ./$RSA_FILE_NAME.pub ~/$SSH_KEY_DIR/$RSA_FILE_NAME.pub;
mv ./$DSA_FILE_NAME ~/$SSH_KEY_DIR/$DSA_FILE_NAME;
mv ./$DSA_FILE_NAME.pub ~/$SSH_KEY_DIR/$DSA_FILE_NAME.pub;

# copy file with public keys to hosts
cp ./$PUB_KEYS_FILE ~/$SSH_KEY_DIR/$PUB_KEYS_FILE

if [ "$LOCAL_HOST_NAME" = "$PRIMARY_HOST" ]; then
	echo
	echo "copy public keys to $STANDBY_HOST hosts";   #-> "and $OBSERVER_HOST"
	cat ./$PUB_KEYS_FILE | ssh $STANDBY_HOST "mkdir -p ~/$SSH_KEY_DIR;touch ~/$SSH_KEY_DIR/$PUB_KEYS_FILE;\
						  cat >> ~/$SSH_KEY_DIR/$PUB_KEYS_FILE;chmod 700 ~/$SSH_KEY_DIR;chmod 600 ~/$SSH_KEY_DIR/$PUB_KEYS_FILE";

#->	cat ./$PUB_KEYS_FILE | ssh $OBSERVER_HOST "mkdir -p ~/$SSH_KEY_DIR;touch ~/$SSH_KEY_DIR/$PUB_KEYS_FILE;\
#->						  cat >> ~/$SSH_KEY_DIR/$PUB_KEYS_FILE;chmod 700 ~/$SSH_KEY_DIR;chmod 600 ~/$SSH_KEY_DIR/$PUB_KEYS_FILE";
elif [ "$LOCAL_HOST_NAME" = "$STANDBY_HOST" ]; then
	echo
	echo "copy public keys to $PRIMARY_HOST";   #-> "and $OBSERVER_HOST"
	cat ./$PUB_KEYS_FILE | ssh $PRIMARY_HOST "mkdir -p ~/$SSH_KEY_DIR;touch ~/$SSH_KEY_DIR/$PUB_KEYS_FILE;\
						  cat >> ~/$SSH_KEY_DIR/$PUB_KEYS_FILE;chmod 700 ~/$SSH_KEY_DIR;chmod 600 ~/$SSH_KEY_DIR/$PUB_KEYS_FILE";

#->	cat ./$PUB_KEYS_FILE | ssh $OBSERVER_HOST "mkdir -p ~/$SSH_KEY_DIR;touch ~/$SSH_KEY_DIR/$PUB_KEYS_FILE;\
#->						  cat >> ~/$SSH_KEY_DIR/$PUB_KEYS_FILE;chmod 700 ~/$SSH_KEY_DIR;chmod 600 ~/$SSH_KEY_DIR/$PUB_KEYS_FILE";
#->elif [ "$LOCAL_HOST_NAME" =  "$OBSERVER_HOST" ]; then
#->	echo
#->	echo "copy public keys to $PRIMARY_HOST and $STANDBY_HOST hosts";
#->	cat ./$PUB_KEYS_FILE | ssh $PRIMARY_HOST "mkdir -p ~/$SSH_KEY_DIR;touch ~/$SSH_KEY_DIR/$PUB_KEYS_FILE;\
#->						  cat >> ~/$SSH_KEY_DIR/$PUB_KEYS_FILE;chmod 700 ~/$SSH_KEY_DIR;chmod 600 ~/$SSH_KEY_DIR/$PUB_KEYS_FILE";
#->
#->	cat ./$PUB_KEYS_FILE | ssh $STANDBY_HOST "mkdir -p ~/$SSH_KEY_DIR;touch ~/$SSH_KEY_DIR/$PUB_KEYS_FILE;\
#->						  cat >> ~/$SSH_KEY_DIR/$PUB_KEYS_FILE;chmod 700 ~/$SSH_KEY_DIR;chmod 600 ~/$SSH_KEY_DIR/$PUB_KEYS_FILE";
fi

# remove local key files
if [[ -f $RSA_FILE_NAME ]] || [[ -f $RSA_FILE_NAME.pub ]]; then
        rm ./$RSA_FILE_NAME*;
fi

if [[ -f $DSA_FILE_NAME ]] || [[ -f $DSA_FILE_NAME.pub ]]; then
        rm ./$DSA_FILE_NAME*;
fi

if [ -f $PUB_KEYS_FILE ]; then
        rm ./$PUB_KEYS_FILE
fi

# TEST ssh
echo;
echo "begin test ssh connect";
if [ "$LOCAL_HOST_NAME" = "$PRIMARY_HOST" ]; then
	ssh $STANDBY_HOST "hostname; date"
#->	ssh $OBSERVER_HOST "hostname; date"
elif [ "$LOCAL_HOST_NAME" = "$STANDBY_HOST" ]; then
	ssh $PRIMARY_HOST "hostname; date"
#->	ssh $OBSERVER_HOST "hostname; date"
#->elif [ "$LOCAL_HOST_NAME" =  "$OBSERVER_HOST" ]; then
#->	ssh $PRIMARY_HOST "hostname; date"
#->	ssh $STANDBY_HOST "hostname; date"
fi

