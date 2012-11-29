#!/bin/sh
#
# Unix migration script for McStas-pre 2.0 for those who want to keep that on their machine
#
#

MCSTAS_WHERE=`which mcstas`
MCSTAS_VERSION=`mcstas -v|head -1|cut -f3 -d\ `
MCSTAS_MAJOR=`echo $MCSTAS_VERSION | cut -f1 -d.`
if [ ! "${MCSTAS_MAJOR}" = 1 ]; then
    echo Sorry, this script is made for McStas versions 1.x only!;
    exit 1;
else 
    MCSTAS_BINDIR=`dirname $MCSTAS_WHERE`
    MCSTAS_LIBDIR=`dirname $MCSTAS_BINDIR`/lib/mcstas
    MCSTAS_NEWBINDIR=$MCSTAS_BINDIR/McStas-$MCSTAS_VERSION
    MCSTAS_NEWLIBDIR=$MCSTAS_LIBDIR-$MCSTAS_VERSION
    MOVE_SCRIPT=/tmp/mcstas-$MCSTAS_VERSION-move
    ENV_SCRIPT=/tmp/mcstas-$MCSTAS_VERSION-environment
    
    # Write migration info to the screen:
    echo Your existing mcstas executable is this one: $MCSTAS_WHERE
    echo - version is $MCSTAS_VERSION
    echo - located in $MCSTAS_BINDIR
    echo - with component library in $MCSTAS_LIBDIR
    echo
    echo The suggested new location for the $MCSTAS_VERSION binaries is: 
    echo \ \ $MCSTAS_BINDIR/McStas-$MCSTAS_VERSION
    echo with the component library in 
    echo \ \ $MCSTAS_NEWLIBDIR
    echo 
    echo To move your installation, please execute the script $MOVE_SCRIPT
    # Write the script:
    echo \#!/bin/sh > $MOVE_SCRIPT
    echo \# Script for moving your McStas $MCSTAS_VERSION installation out of the way before installation of 2.0 >> $MOVE_SCRIPT
    echo >> $MOVE_SCRIPT
    echo \# Create directory for the binaries >> $MOVE_SCRIPT
    echo sudo mkdir $MCSTAS_NEWBINDIR >> $MOVE_SCRIPT
    echo \# Move component library to $MCSTAS_NEWLIBDIR >> $MOVE_SCRIPT
    echo sudo cp -rp $MCSTAS_LIBDIR $MCSTAS_NEWLIBDIR >> $MOVE_SCRIPT
    echo \# Move the binaries to $MCSTAS_NEWBINDIR >> $MOVE_SCRIPT
    for bincomp in `echo mcconvert mcdaemon mcdisplay mcdoc mcformat mcformatgui mcgui mcplot mcresplot mcrun mcstas mcstas2vitess`
    do 
	echo sudo cp $MCSTAS_BINDIR/$bincomp $MCSTAS_NEWBINDIR/ >> $MOVE_SCRIPT;
    done
    echo \# Finally, copy environment script  to /usr/local/bin... >> $MOVE_SCRIPT;
    echo sudo cp $ENV_SCRIPT /usr/local/bin >> $MOVE_SCRIPT;
    # Write environment script info to screen
    echo
    echo Afterwards, the script $ENV_SCRIPT can be used to run your 
    echo relocated McStas $MCSTAS_VERSION. \(Migration script places a copy in /usr/local/bin\)
    echo
    # Write environment script info to Enviroment script
    echo \#!/bin/sh > $ENV_SCRIPT
    echo export MCSTAS=$MCSTAS_NEWLIBDIR >> $ENV_SCRIPT
    echo export PATH=$MCSTAS_NEWBINDIR:\$PATH >> $ENV_SCRIPT
    echo echo >> $ENV_SCRIPT
    echo echo The new shell started here is now set up for running this version of mcstas: >> $ENV_SCRIPT
    echo echo >> $ENV_SCRIPT
    echo mcstas -v >> $ENV_SCRIPT
    echo echo >> $ENV_SCRIPT
    echo echo To end using this version of mcstas, exit this shell. >> $ENV_SCRIPT
    echo echo >> $ENV_SCRIPT
    echo export PS1=\'McStas $MCSTAS_VERSION env \\w\\$ \>\ \' >> $ENV_SCRIPT 
    echo /bin/sh >> $ENV_SCRIPT
    echo >> $ENV_SCRIPT
    
    # Make the scripts executable:
    chmod a+x $ENV_SCRIPT
    chmod a+x $MOVE_SCRIPT
    
    # If this is Debian and mcstas is installed, recommend to uninstall that before installing 2.0
    if [ -f /etc/debian_version ]; then
	echo Debian machine - checking if mcstas was previously installed
	MCSTAS_FROM_DEB=`dpkg -l \*mcstas\* |grep ^ii`
	if [ "$?" = "0" ]; then
	    echo Found these McStas-related packages on your system:;
	    echo ;
	    dpkg -l \*mcstas\* |grep ^ii ;
	    echo ;
	    echo Our recommendation is that you uninstall these packages once you have run $MOVE_SCRIPT ;
	fi
    fi
fi