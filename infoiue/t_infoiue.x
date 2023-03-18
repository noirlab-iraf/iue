include	<error.h>
include	<imhdr.h>
include	"iinfo.h"

include	<error.h>

#--------------------------------------------------------------------28 Apr 98--
.help t_infoiue.x Apr98 iuetools/infoiue
.ih
NAME
.nf
  t_infoiue - Task to print information from IUE image headers
  kw_fetchs - Fetch string-valued keyword from image header
  kw_fetchh - Fetch keyword from image header & return in sexigesimal format
  kw_fetchr - Fetch keyword from image header & return in floating format
.fi
.ih
DESCRIPTION
.endhelp
#-------------------------------------------------------------------------------
#  T_INFOIUE -	Task to print information from IUE image headers.  

procedure t_infoiue ()

# Declarations:
#int	i, n			# generic
pointer	im			# image descriptor
char	image[SZ_FNAME]		# single input image
pointer	immap()			# open an image
int	imtgetim()		# get the next image name in the list
pointer	imtopenp()		# open an image list
pointer	kw			# keyword structure
pointer	kw_alloc()		# allocate kw structure
int	len			# length of string
pointer	list			# image list
int	strlen()		# return length of string
#int	wd_count()		# returns no. words in a list

errchk	imgstr

begin
	kw = kw_alloc ()

	# Get the input image name list.
	list = imtopenp ("input")
	call printf ("\n%15w IUE Image Header Summary\n")

	while (imtgetim (list, image, SZ_FNAME) != EOF) {

	    # Open the input primary image.
	    len = strlen (image)
	    if (image[len] != ']')
		call strcat ("[0]", image, SZ_FNAME)
	    iferr (im = immap (image, READ_ONLY, 0)) {
	    	call erract (EA_WARN)
		next
	    }

	    # Retrieve & print all keywords in the general list.
	    iferr {
	    	call imgstr (im, "CAMERA", II_CAMERA(kw), SZ_KEYWD)
	    	call imgstr (im, "IMAGE", II_IMAGE(kw), SZ_KEYWD)
	    	call imgstr (im, "DISPERSN", II_DISPERSN(kw), SZ_KEYWD)
	    	call imgstr (im, "APERTURE", II_APERTURE(kw), SZ_KEYWD)
	    } then 
		call erract (EA_WARN)

	    call kw_hdtostring (kw)

	    # Retrieve & print the aperture-specific keywords.
	    call kw_fetchs (im, "LOBJECT", II_LAPKW(kw), SZ_KEYWD)
	    call kw_fetchs (im, "SOBJECT", II_SAPKW(kw), SZ_KEYWD)
	    call kw_tostring (kw, "Target")

	    call kw_fetchh (im, "LRA", 15., II_LAPKW(kw), SZ_KEYWD)
	    call kw_fetchh (im, "SRA", 15., II_SAPKW(kw), SZ_KEYWD)
	    call kw_tostring (kw, "Target R.A.")

	    call kw_fetchh (im, "LDEC", 1., II_LAPKW(kw), SZ_KEYWD)
	    call kw_fetchh (im, "SDEC", 1., II_SAPKW(kw), SZ_KEYWD)
	    call kw_tostring (kw, "Target Dec.")

	    call kw_fetchs (im, "LDATEOBS", II_LAPKW(kw), SZ_KEYWD)
	    call kw_fetchs (im, "SDATEOBS", II_SAPKW(kw), SZ_KEYWD)
	    call kw_tostring (kw, "Observ. Date")

	    call kw_fetchs (im, "LTIMEOBS", II_LAPKW(kw), SZ_KEYWD)
	    call kw_fetchs (im, "STIMEOBS", II_SAPKW(kw), SZ_KEYWD)
	    call kw_tostring (kw, "Observ. Time")

	    call kw_fetchr (im, "LEXPTIME", II_LAPKW(kw), SZ_KEYWD)
	    call kw_fetchr (im, "SEXPTIME", II_SAPKW(kw), SZ_KEYWD)
	    call kw_tostring (kw, "Integration Time")

	    call kw_fetchs (im, "LEXPTRMD", II_LAPKW(kw), SZ_KEYWD)
	    call kw_fetchs (im, "SEXPTRMD", II_SAPKW(kw), SZ_KEYWD)
	    call kw_tostring (kw, "Trail Mode")

	    call kw_fetchs (im, "LEXPMULT", II_LAPKW(kw), SZ_KEYWD)
	    call kw_fetchs (im, "SEXPMULT", II_SAPKW(kw), SZ_KEYWD)
	    call kw_tostring (kw, "Multiple Exposure?")

	    call kw_fetchs (im, "LEXPSEGM", II_LAPKW(kw), SZ_KEYWD)
	    call kw_fetchs (im, "SEXPSEGM", II_SAPKW(kw), SZ_KEYWD)
	    call kw_tostring (kw, "Segmented Exposure?")

	    call imunmap (im)
	}
	call imtclose (list)
	call kw_free (kw)
end


#-------------------------------------------------------------------------------
#  KW_FETCHS - Fetch string-valued keyword from image header.  

procedure kw_fetchs (im, kw, kw_val, maxchars)

# Arguments:
pointer	im		#I image descriptor
char	kw[ARB]		#I name of keyword to fetch
char	kw_val[ARB]	#O value of keyword
int	maxchars	#I maximum chars for keyword string

errchk	imgstr

begin
	iferr (call imgstr (im, kw, kw_val, maxchars))
	    call strcpy ("N/A", kw_val, maxchars)
end


#-------------------------------------------------------------------------------
#  KW_FETCHR - 	Fetch TY_REAL keyword from image header & return as string.  

procedure kw_fetchr (im, kw, kw_val, maxchars)

# Arguments:
pointer	im		#I image descriptor
char	kw[ARB]		#I name of keyword to fetch
char	kw_val[ARB]	#O value of keyword
int	maxchars	#I maximum chars for keyword string

# Declarations:
real	imgetr()	# get image header parameter, TY_REAL
real	rval		# generic

errchk	imgetr

begin
	iferr (rval = imgetr (im, kw))
	    call strcpy ("N/A", kw_val, maxchars)

	else {
	    call sprintf (kw_val, maxchars, "%9.3f")
		call pargr (rval)
	}
end


#-------------------------------------------------------------------------------
#  KW_FETCHH - 	Fetch TY_REAL keyword from image header & return as string in 
#		sexigesimal format.  

procedure kw_fetchh (im, kw, scale, kw_val, maxchars)

# Arguments:
pointer	im		#I image descriptor
char	kw[ARB]		#I name of keyword to fetch
real	scale		#I scale factor for fetched value
char	kw_val[ARB]	#O value of keyword
int	maxchars	#I maximum chars for keyword string

# Declarations:
real	imgetr()	# get image header parameter, TY_REAL
real	rval		# generic

errchk	imgetr

begin
	iferr (rval = imgetr (im, kw))
	    call strcpy ("N/A", kw_val, maxchars)

	else {
	    rval = rval / scale
	    call sprintf (kw_val, maxchars, "%11.1h")
		call pargr (rval)
	}
end


