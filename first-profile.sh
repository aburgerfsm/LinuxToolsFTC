#!/bin/bash
function ftc-create-new-workspace(){
set -x
PWD=`pwd`
GITURL=https://github.com/ftctechnh/ftc_app.git
GITDIR=ftc_app
if [ ! -d $GITDIR ]; then 
  git clone $GITURL $GITDIR
  cd $GITDIR
fi 
STATUS="`git remote show origin 2>&1 | grep https://github.com/ftctechnh/ftc_app.git > /dev/null 2>&1 ; echo $?`" 
if [ "$STATUS" == "0" ] ; then 
  git remote rm origin
fi
STATUS="`git remote show upstream 2>&1 | grep https://github.com/ftctechnh/ftc_app.git > /dev/null 2>&1 ; echo $?`" 
if [ "$STATUS" != "0" ] ; then 
  STATUS="`git status >/dev/null 2>&1 ; echo $?`" 
  if [ "$STATUS" == "0" ] ; then 
    git remote add upstream $GITURL
  fi 
fi 
set +x
}
