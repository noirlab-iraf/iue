# Copyright restrictions apply - see iue$doc/copyright.iue

include	<imhdr.h>
include	<tbset.h>
include	<error.h>
include	"../mx.h"

#--------------------------------------------------------------------16 Jul 99--
.help mxtomulti.x Jul99 iue/iuetools
.ih
NAME
.nf
    mxexpand - Task to expand the wavelength zero-point & delta-wave to an array
.fi
.ih 
Revision History
.nf
   16-Jul-99	RAShaw		Initial version
.fi
.endhelp
#-------------------------------------------------------------------------------
#  MXTOMULTISPEC - Task to translate IUE extracted spectra (MXLO and MXHI 
#		tables) to NOAO "multispec" images.  

procedure mxtomultispec ()

# Declarations:
pointer	cp[MX_NCOLS]		# table column pointers
int	dispersion		# dispersion mode
char	errmsg[SZ_LINE]		# error message string
int	get_disp()		# determine dispersion mode
pointer	im			# output image descriptor
pointer	immap()			# open an image 
pointer	imtopenp()		# open an image template list
int	imtgetim()		# get the next image from a template list
pointer	imlist, list		# output image, input table lists
char	inhdr[SZ_FNAME]		# input FITS primary header (image)
char	intable[SZ_FNAME]	# input MXLO or MXHI FITS table
char	output[SZ_FNAME]	# output image
pointer	primary			# input FITS primary header
int	tbnget()		# get next table name from list
pointer tbnopenp()		# open table list
pointer	tbtopn()		# open table
pointer	tp			# table descriptor

errchk	get_disp

begin
	# Get the input table name list and output image name list.
	list = tbnopenp ("intable")
	imlist = imtopenp ("output")
	while (tbnget (list, intable, SZ_FNAME) != EOF && 
		imtgetim (imlist, output, SZ_FNAME) != EOF) {

	    # Open the FITS primary header.
	    call strcpy (intable, inhdr, SZ_FNAME)
	    call strcat ("[0]", inhdr, SZ_FNAME)
	    iferr (primary = immap (inhdr, READ_ONLY, NULL)) {
		call strcpy ("Error opening input table header %s", 
				errmsg, SZ_LINE)
		    call pargstr (output)
	    	call erract (EA_WARN)
		next
	    }

	    # Create the output image.
	    iferr (im = immap (output, NEW_COPY, primary)) {
		call strcpy ("Error opening output image %s", errmsg, SZ_LINE)
		    call pargstr (output)
	    	call erract (EA_WARN)
		call imunmap (primary)
		next
	    }
	    call imunmap (primary)

	    # Open the FITS table extension.
	    iferr (tp = tbtopn (intable, READ_ONLY, NULL)) {
		call strcpy ("Error opening input table %s", errmsg, SZ_LINE)
		    call pargstr (intable)
	    	call erract (EA_WARN)
		next
	    }

	    dispersion = get_disp (tp)

	    iferr {

	    	# Fetch the various column pointers.
	    	call get_colptr (tp, "WAVELENGTH", cp[W0_COL])
	    	call get_colptr (tp, "DELTAW",     cp[DW_COL])
	    	call get_colptr (tp, "NPOINTS",    cp[NP_COL])

	    	if (dispersion == DS_HIGH) {
	    	    call get_colptr (tp, "STARTPIX", cp[SP_COL])
	    	    call get_colptr (tp, "ORDER",    cp[OD_COL])
	    	    call get_colptr (tp, "ABS_CAL",  cp[FL_COL])
	    	}
		else
	    	    call get_colptr (tp, "FLUX",    cp[FL_COL])

	    	# Process each spectrum in the file.
	    	call mk_mswcs (tp, cp, im, dispersion)
		call tbtclo (tp)
		call imunmap (im)

	    } then {

		# On error, inform the user of the problem, delete the output 
		# image, and skip to the next file in the list.
		call erract (EA_WARN)
		call imunmap (im)
		call delete (output)
		call tbtclo (tp)
		call printf ("File %s not created\n")
		call pargstr (output)
		next
	    }

	    # Notify user of success.
	    call printf ("Converted file %s --> %s\n")
	    call pargstr (intable)
	    call pargstr (output)
	}
	call tbnclose (list)
	call imtclose (imlist)
end


