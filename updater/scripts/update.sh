#!/bin/sh
if md5sum --status -c verify.hash; then
	    # The MD5 sum matched
	    echo "Applying update"
	    xdelta3 -d -s ../volumio_current.sqsh ./delta.patch ../volumio_update.sqsh
	    echo "Backing up previous image"
	    mv ../volumio_current.sqsh ../volumio_fallback.sqsh
	    echo "Installing new image"
	    mv ../volumio_update.sqsh ../volumio_current.sqsh
	    echo "Verifying final image"
	    
	    if md5sum --status -c final.hash; then
		    exit 0
	    else
		    echo "Update failed. Folling back to previous image"
		    mv ../volumio_fallback.sqsh ../volumio_current.sqsh
		    exit 1
	    fi

else
	    # The MD5 sum didn't match
	    echo "Hash verify failed. Aborting."
	    exit 1
fi
