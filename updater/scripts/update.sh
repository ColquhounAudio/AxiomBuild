#!/bin/sh
if md5sum --status -c verify.hash; then
	    # The MD5 sum matched
	    echo "Applying update"
	    rm -f ../*.sha256
	    rm -f ../*.tar.gz
	    xdelta3 -d -s ../volumio_current.sqsh ./delta.patch ../volumio_update.sqsh
	    echo "Backing up previous image"
	    mv ../volumio_current.sqsh ../volumio_fallback.sqsh
	    echo "Installing new image"
	    mv ../volumio_update.sqsh ../volumio_current.sqsh
	    echo "Verifying final image"
	    sync    
	    if md5sum --status -c final.hash; then
		    exit 0
	    else
		    echo "Update failed. Folling back to previous image"
		    mv ../volumio_fallback.sqsh ../volumio_current.sqsh
		    sync
		    exit 1
	    fi

else
	    # The MD5 sum didn't match
	    echo "Hash verify failed. Aborting."
	    sync
	    exit 1
fi
