#!/usr/bin/env zsh

export test_description="Testing tomb creation"

source ./setup
test_cleanup

test_export "test"
test_expect_success 'Testing tomb creation: dig, forge and lock' '
    tt_dig -s 20 &&
    tt_forge --tomb-pwd $DUMMYPASS &&
    print $DUMMYPASS \
        | gpg --batch --passphrase-fd 0 --no-tty --no-options -d $tomb_key \
        | xxd &&
    tt_lock --tomb-pwd $DUMMYPASS
    '

if test_have_prereq DOAS; then
    test_export "doas_test"
    test_expect_success 'Testing tomb creation: dig, forge and lock (using doas instead of sudo)' '
        tt_dig --sudo doas -s 20 &&
        tt_forge --sudo doas --tomb-pwd $DUMMYPASS &&
        print $DUMMYPASS \
            | gpg --batch --passphrase-fd 0 --no-tty --no-options -d $tomb_key \
            | xxd &&
        tt_lock --sudo doas --tomb-pwd $DUMMYPASS
        '
fi

if test_have_prereq BTRFS; then
    test_export "btrfs"
    test_expect_success 'Testing tomb creation using BTRFS filesystem' '
    tt_dig -s 120 &&
    tt_forge --tomb-pwd $DUMMYPASS &&
    print $DUMMYPASS \
        | gpg --batch --passphrase-fd 0 --no-tty --no-options -d $tomb_key \
        | xxd &&
    tt_lock --tomb-pwd $DUMMYPASS --filesystem btrfs
    '

    test_export "btrfsmixed"
    test_expect_success 'Testing tomb creation using BTRFS mixedmode filesystem' '
    tt_dig -s 20 &&
    tt_forge --tomb-pwd $DUMMYPASS &&
    print $DUMMYPASS \
        | gpg --batch --passphrase-fd 0 --no-tty --no-options -d $tomb_key \
        | xxd &&
    tt_lock --tomb-pwd $DUMMYPASS --filesystem btrfsmixedmode
    '
fi

test_done
