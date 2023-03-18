# Copyright restrictions apply - see iue$doc/copyright.iue

include	<tbset.h>
include	<error.h>
include	"../mx.h"

#--------------------------------------------------------------------16 Jul 99--
.help mxexpand.x Jul99 iue/iuetools
.ih
NAME
    mxexpand - Task to expand the wavelength zero-point & delta-wave to an array
  mk_wvarray - Expand the initial & delta wavelength to an array
    tfixname - Create the output table name. 
.ih 
Revision History
.nf
   09-Dec-97	RAShaw		Initial version
   14-May-99	RAShaw		Added a "tbtclo" call to actually update 
				output file (!)
.fi
.endhelp
#-------------------------------------------------------------------------------
#  MXEXPAND - 	Task to expand the wavelength zero-point and delta-wave to 
#		wavelength arrays in rows of IUE MXLO and MXHI tables.  

procedure mxexpand ()

# Declarations:
pointer	cp[5]			# table column pointer
char	directory[SZ_FNAME]	# name of output directory
int	dispersion		# dispersion mode
char	errmsg[SZ_LINE]		# error message string
int	get_disp()		# determine dispersion mode
char	intable[SZ_FNAME]	# input MXLO or MXHI FITS table
char	outtable[SZ_FNAME]	# output MXLO or MXHI FITS table
pointer	list			# input table list
bool	renamed			# was the input file renamed?
int	sz_wvarr		# size of wavelength array in table
int	tbnget()		# get next table name from list
pointer tbnopenp()		# open table list
pointer	tbtopn()		# open table
bool	tfixname()		# was the input file renamed?
pointer	tp			# table descriptor

errchk	get_disp

begin
	# Get the input/output table name list and output directory.
	call clgstr ("directory", directory, SZ_FNAME)
	list = tbnopenp ("intable")
	while (tbnget (list, intable, SZ_LINE) != EOF) {

	    # Change table name if needed.
	    renamed = tfixname (intable, directory, outtable)
	    if (renamed) {
	    	iferr (call fcopy (intable, outtable)) {
		    call erract (EA_WARN)
		    call printf ("File %s not created\n")
			call pargstr (outtable)
		    next
		}
	    }

	    # Open the output table & fetch size.
	    iferr (tp = tbtopn (outtable, READ_WRITE, NULL)) {
		call strcpy ("Error opening input table %s", errmsg, SZ_LINE)
		    call pargstr (intable)
	    	call erract (EA_WARN)
		next
	    }

	    dispersion = get_disp (tp)

	    iferr {

	    	# Fetch the various column pointers.
	    	call get_colptr (tp, "WAVELENGTH", cp[W0_COL])
	    	call get_colptr (tp, "DELTAW", cp[DW_COL])
	    	call get_colptr (tp, "NPOINTS", cp[NP_COL])
	    	call tbegti (tp, cp[NP_COL], 1, sz_wvarr)

	    	if (dispersion == DS_HIGH) {
	    	    call get_colptr (tp, "STARTPIX", cp[SP_COL])
		    sz_wvarr = SZ_IUELINE
	    	}

	    	# Process each spectrum in the file.
	    	call mk_wvarray (tp, cp, dispersion, sz_wvarr)
		call tbtclo (tp)		# Fix added on 14May99

	    } then {

		# On error, inform the user of the problem, delete the temp 
		# file (if any), and skip to the next file in the list.
		call erract (EA_WARN)
		if (renamed) {
		    call delete (outtable)
		    call printf ("File %s not created\n")

		} else
		    call printf ("File %s not updated\n")

		call pargstr (outtable)
		next
	    }

	    # Notify user of success.
	    call printf ("Converted file %s --> %s\n")
	    call pargstr (intable)
	    call pargstr (outtable)
	}
end


#-------------------------------------------------------------------------------
#  MK_WVARRAY -	Expand the wavelength zero-point and delta-wave to 
#		wavelength arrays in rows of IUE MXLO and MXHI tables.  

procedure mk_wvarray (tp, cp, dispersion, sz_wvarr)

# Calling arguments:
pointer	tp			# I: table descriptor
pointer	cp[ARB]			# I: column pointers
int	dispersion		# I: dispersion mode
int	sz_wvarr		# I: size of wavelength array in table

# Declarations:
double	delta_w			# delta wavelength
int	i, j, row		# loop indexes
int	n_rows			# no. table rows
int	pix_0			# reference pixel corresponding to wave_0
pointer	sp			# stack memory pointer
int	tbpsta()		# return table info
pointer	wave			# wavelength array
double	wave_0			# wavelength @reference pixel
char	wavarr_col[SZ_COLNAME]	# Column name for wavelength array

string	units	"ANGSTROM"
string	format	"%15.7g"

# Memory management.
define	Wave	Memd[wave+$1-1]

errchk	tbaptd

begin
	# If no rows are found in the input table, error out.
	n_rows = tbpsta (tp, TBL_NROWS)
	if (n_rows <= 0) 
	    call error (1, "No rows in input table.")

	# Allocate wavelength array.
	call smark (sp)
	call salloc (wave, sz_wvarr, TY_DOUBLE)

	# Define a new column for the wavelength array. 
	# Make sure it isn't defined first. 
	call clgstr ("wvarr_col", wavarr_col, SZ_COLNAME)
	ifnoerr (call get_colptr (tp, wavarr_col, cp[WA_COL]))
	    call error (1, "Wavelength array column already exists")

	call tbcdef (tp, cp[WA_COL], wavarr_col, units, format, TY_DOUBLE, 
			sz_wvarr, 1)

	# Process each spectrum.
	do row = 1, n_rows {

	    # Get the wavelength parameters from table.
	    call tbegtd (tp, cp[W0_COL], row, wave_0)
	    call tbegtd (tp, cp[DW_COL], row, delta_w)
	    call amovkd (INDEFD, Wave(1), sz_wvarr)

	    if (dispersion == DS_HIGH) {
	    	call tbegti (tp, cp[SP_COL], row, pix_0)
	    } else
	    	pix_0 = 1

	    # Compute the wavelength array.
	    do i = 1, sz_wvarr {
		j = i - pix_0
	    	Wave(i) = wave_0 + delta_w * j
	    }

	    # Write the array to the output table.
	    call tbaptd (tp, cp[WA_COL], row, Wave(1), 1, sz_wvarr)
	}

	call sfree (sp)
end


#-------------------------------------------------------------------------------
#  TFIXNAME -	Create the output table name. 

bool procedure tfixname (in_name, directory, out_name)

# Calling arguments:
char	in_name[ARB]		# I: name of input table
char	directory[ARB]		# I: name of output directory
char	out_name[SZ_FNAME]	# O: name of output table

# Declarations:
int	ip			# index of substring
int	len			# string length 
char	root[SZ_FNAME]		# root name of the table (minus selectors)
int	strlen()		# return length of string
int	strsearch()		# substring search
char	sx1[SZ_FNAME]		# generic
char	sx2[SZ_FNAME]		# generic

begin
	# Determine if the input table extension begins with ".mx".
	call strcpy (in_name, sx1, SZ_FNAME)
	call strlwr (sx1)

	# Find the file extension separator (the period).
	ip = strsearch (sx1, ".mx") - 3

	if (ip > 0) {

	    # If the extension is .mx?? then rename to <input>mx??.fits.
	    len = strlen (directory)
	    call strcpy (directory, out_name, SZ_FNAME)
	    call strcat (in_name, out_name, ip-1+len)
	    call strcat (in_name[ip+1], out_name, ip+4+len)
	    call strcat (".fits", out_name, SZ_FNAME)
	    return (true)

	} else {

	    # If the extension is not .mx??, strip off any row/column selectors.
	    call rdselect (in_name, root, sx1, sx2, SZ_FNAME)
	    call strcpy (root, in_name, SZ_FNAME)
	    call strcpy (directory, out_name, SZ_FNAME)
	    call strcat (root, out_name, SZ_FNAME)
	    if (directory[1] != EOS)
		return (true)
	    else
		return (false)
	}
end


