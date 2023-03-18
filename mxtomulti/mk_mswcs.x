# Copyright restrictions apply - see iue$doc/copyright.iue

include	<imhdr.h>
include	<tbset.h>
include	<error.h>
include	"../mx.h"

define	SZ_FITS_STRING	 68
define	SZ_FITS_KEYWD	  8

#--------------------------------------------------------------------16 Jul 99--
.help mk_mswcs.x Jul99 iue/iuetools
.ih
NAME
.nf
    mk_mswcs - Create header keywords for the multispec WCS
  imhdr_init - Initialize the input image header
.fi
.ih 
Revision History
.nf
   16-Jul-99	RAShaw		Initial version
.fi
.endhelp
#-------------------------------------------------------------------------------
#  MK_MSWCS -	Expand the wavelength zero-point and delta-wave to 
#		wavelength arrays in rows of IUE MXLO and MXHI tables.  

procedure mk_mswcs (tp, cp, im, dispersion)

# Calling arguments:
pointer	tp			# I: table descriptor
pointer	cp[ARB]			# I: column pointers
pointer	im			#U: output image descriptor
int	dispersion		# I: dispersion mode

# Declarations:
double	delta_w			# delta wavelength
pointer	flux			# flux array
int	i			# loop indexes
pointer	impl2r()		# put a line into a 2-D image
int	n_pix			# no. valid pixels in current order
int	n_rows			# no. table rows
int	pix_0			# reference pixel corresponding to wave_0
int	row			# input table row
int	order			# current spectral order
#char	s1[SZ_LINE]		# generic
pointer	sp			# stack memory pointer
int	sz_axis1		# max. size of the spectrum
int	tbagtr()		# get an array from a table cell
int	tbpsta()		# return table info
char	key[SZ_FITS_KEYWD+1]	# FITS keyword
char	value[SZ_FITS_STRING+1]	# FITS keyword value
double	wave_0			# wavelength @reference pixel

string	WAT0_001	"system=multispec "
string	WAT1_001	"wtype=multispec label=Wavelength units=Angstroms"
string	WAT2_001	"wtype=multispec "
define	VAL_FORMAT	"spec%d = \"%d %d 0 %14.9f %15.13f %d 0. 0. 0.\" "

# Memory management.
define	Flux	Memr[flux+$1-1]

errchk	tbaptd, tbhgtt

begin
	# If no rows are found in the input table, error out.
	n_rows = tbpsta (tp, TBL_NROWS)
	if (n_rows <= 0) 
	    call error (1, "No rows in input table.")

	# Allocate wavelength array.
	if (dispersion == DS_HIGH) 
	    sz_axis1 = SZ_IUELINE
	else
	    sz_axis1 = 640
	call smark (sp)
	call salloc (flux, sz_axis1, TY_REAL)

	# Initialize the image WCS attributes
	call imhdr_init (tp, cp, im, sz_axis1, n_rows, TY_REAL)

	# Output the initial WAT keywords.
	call imastr (im, "WAT0_001", WAT0_001)
	call imastr (im, "WAT1_001", WAT1_001)
	call imastr (im, "WAT2_001", WAT2_001)

	# Process each spectrum.
	do row = 1, n_rows {

	    # Get the wavelength parameters from table.
	    call tbegtd (tp, cp[W0_COL], row, wave_0)
	    call tbegtd (tp, cp[DW_COL], row, delta_w)
	    call tbegti (tp, cp[NP_COL], row, n_pix)

	    if (dispersion == DS_HIGH) {
	    	call tbegti (tp, cp[OD_COL], row, order)
	    	call tbegti (tp, cp[SP_COL], row, pix_0)
	    } 
	    else {
		order = 1
	    	pix_0 = 1
	    }

	    # Write the spectrum WCS description to the image header.
	    call sprintf (value, SZ_FITS_STRING, VAL_FORMAT)
		call pargi (row)
		call pargi (row)
		call pargi (order)
		call pargd (wave_0)
		call pargd (delta_w)
		call pargi (n_pix)

	    call sprintf (key, SZ_FITS_KEYWD, "WAT2_%03d")
		call pargi (row+1)
	    call imastr (im, key, value)

	    # Populate the flux array.
	    call aclrr (Flux(1), sz_axis1)
	    i = tbagtr (tp, cp[FL_COL], row, Flux(1), pix_0, n_pix)
	    call amovr (Flux(1), Memr[impl2r (im, row)], sz_axis1)

#	    call tbhgtt (tp, "CAMERA", s1, SZ_LINE)
#	    call printf ("Camera in use is: %s\n")
#		call pargstr (s1)
	}

	call sfree (sp)
end


#-------------------------------------------------------------------------------
#  IMHDR_INIT -	Initialize the output image header.  

procedure imhdr_init (tp, cp, im, sz_axis1, sz_axis2, pix_type)

# Calling arguments:
pointer	tp			#I: input table descriptor
pointer	cp[ARB]			#I: column pointers
pointer	im			#U: image descriptor
int	sz_axis1		#I: max. size of the spectrum
int	sz_axis2		#I: max. number of the spectra
int	pix_type		#I: pixel data type

# Declarations:

begin
	IM_NDIM(im) = 2
	IM_LEN(im,1) = sz_axis1
	IM_LEN(im,2) = sz_axis2
	IM_PIXTYPE(im) = pix_type
	call imaddi (im, "WCSDIM", 2)
	call imastr (im, "CTYPE1", "MULTISPE")
	call imastr (im, "CTYPE2", "MULTISPE")
	call imaddr (im, "CD1_1", 1.)
	call imaddr (im, "CD2_2", 1.)
	call imaddr (im, "LTM1_1", 1.)
	call imaddr (im, "LTM2_2", 1.)
end


