include	"iinfo.h"

#--------------------------------------------------------------------16 Jul 99--
.help kw_struct.x Apr98 iuetools/iue_info
.ih
NAME
.nf
     kw_alloc - Allocate the image header keyword structure
      kw_free - Free the image header keyword structure
kw_hdtostring - Pretty-print the image header keyword structure.  
  kw_tostring - Pretty-print generic image header keyword pairs.  
.fi
.ih
DESCRIPTION
.endhelp
#-------------------------------------------------------------------------------
#  KW_ALLOC -	Allocate the image header keyword structure.  

pointer procedure kw_alloc ()

# Arguments:
pointer	kw		#O pointer to structure

errchk	calloc

begin
	call calloc (kw, LEN_KW, TY_STRUCT)

	call calloc (II_CAMERA_PTR(kw),   SZ_KEYWD, TY_CHAR)
	call calloc (II_IMAGE_PTR(kw),    SZ_KEYWD, TY_CHAR)
	call calloc (II_DISPERSN_PTR(kw), SZ_KEYWD, TY_CHAR)
	call calloc (II_APERTURE_PTR(kw), SZ_KEYWD, TY_CHAR)
	call calloc (II_LAPKW_PTR(kw),   SZ_KEYWD, TY_CHAR)
	call calloc (II_SAPKW_PTR(kw),   SZ_KEYWD, TY_CHAR)
	return (kw)
end


#-------------------------------------------------------------------------------
#  KW_FREE -	Free the image header keyword structure.  

procedure kw_free (kw)

# Arguments:
pointer	kw		#I pointer to structure

begin
	call mfree (II_CAMERA_PTR(kw),   TY_CHAR)
	call mfree (II_IMAGE_PTR(kw),    TY_CHAR)
	call mfree (II_DISPERSN_PTR(kw), TY_CHAR)
	call mfree (II_APERTURE_PTR(kw), TY_CHAR)
	call mfree (II_LAPKW_PTR(kw),    TY_CHAR)
	call mfree (II_SAPKW_PTR(kw),    TY_CHAR)

	call mfree (kw, TY_STRUCT)
end


#-------------------------------------------------------------------------------
#  KW_HDTOSTRING - Pretty-print the image header keyword structure.  

procedure kw_hdtostring (kw)

# Arguments:
pointer	kw		#I pointer to structure

begin
	# Print the generic header info.
	call printf ("\n%15w %15s %-16s\n")
	    call pargstr ("Camera:")
	    call pargstr (II_CAMERA(kw))

	call printf ("%15w %15s %-16s\n")
	    call pargstr ("Image:")
	    call pargstr (II_IMAGE(kw))

	call printf ("%15w %15s %-16s\n")
	    call pargstr ("Dispersion:")
	    call pargstr (II_DISPERSN(kw))

	call printf ("%15w %15s %-16s\n")
	    call pargstr ("Aperture:")
	    call pargstr (II_APERTURE(kw))

	# Print the aperture-specific info.
	call printf ("\n%22w Large Aperture    Small Aperture\n") 
	call flush (STDOUT)
end


#-------------------------------------------------------------------------------
#  KW_TOSTRING - Pretty-print generic image header keyword pairs.  

procedure kw_tostring (kw, s1)

# Arguments:
pointer	kw		#I pointer to structure
char	s1[ARB]		#I title string

begin
	# Print the aperture-specific keyword pair.
	call printf (" %20s: %-16s  %-16s\n")
	    call pargstr (s1)
	    call pargstr (II_LAPKW(kw))
	    call pargstr (II_SAPKW(kw))
	call flush (STDOUT)
end


