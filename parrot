#!/bin/sh

# number of tests run in parallel.
TEST_JOBS=6

# number of parallel make jobs.  NOT USED YET.
MAKE_JOBS=6

# quieter test harness.
HARNESS_VERBOSE=-2

# email to submit as.
SMOLDER_SUBMITTER=


export SMOLDER_SUBMITTER TEST_JOBS HARNESS_VERBOSE

old_head=`git rev-parse master`
git pull -q
new_head=`git rev-parse master`

# nothing to do...
[ -n "$old_head" -a "$old_head" = "$new_head" ] && exit;

FILE_PATTERN='\.(pm|[chtly]|in|ops|pir|pmc|tg)$'

if git diff --name-only "$old_head..$new_head" | grep -qE $FILE_PATTERN
then (
    set -e

    PARROT_SMOKE_DIR=`mktemp -d`
    [ -n "$PARROT_SMOKE_DIR" ] || exit;

    git checkout-index --prefix=${PARROT_SMOKE_DIR}/ -a
    cd $PARROT_SMOKE_DIR

    perl Configure.pl --silent
    make --silent -j6
    make --silent smoke

    rm -rf $PARROT_SMOKE_DIR
  )
fi

