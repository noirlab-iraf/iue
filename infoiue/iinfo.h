#  iinfo.h	IUE_INFO source symbolics.			12-Apr-98

define	AP_KWD	"|DATEOBS|TIMEOBS|EXPTRMD|EXPSEGM|EXPTIME|RA|DEC|OBJECT|"
define	GEN_KWD	"|CAMERA|IMAGE|DISPERSN|APERTURE|"

#------------------------------------------------------------------------------
# IUE_INFO symbolics
define	SZ_KEYWD	15		# size of header keyword strings

#------------------------------------------------------------------------------
# IUE_INFO structure definition
define	II_CAMERA_PTR	Memi[$1+0]	# Camera name ptr
define	II_IMAGE_PTR	Memi[$1+1]	# Image name ptr
define	II_DISPERSN_PTR	Memi[$1+2]	# Dispersion name ptr
define	II_APERTURE_PTR	Memi[$1+3]	# Aperture name ptr
define	II_LAPKW_PTR	Memi[$1+4]	# ptr to Large-Ap-specific Keyword
define	II_SAPKW_PTR	Memi[$1+5]	# ptr to Large-Ap-specific Keyword

define	LEN_KW		6		# size of this structure

#------------------------------------------------------------------------------
# Memory management:
define	II_CAMERA	Memc[II_CAMERA_PTR($1)]
define	II_IMAGE	Memc[II_IMAGE_PTR($1)]
define	II_DISPERSN	Memc[II_DISPERSN_PTR($1)]
define	II_APERTURE	Memc[II_APERTURE_PTR($1)]
define	II_LAPKW	Memc[II_LAPKW_PTR($1)]
define	II_SAPKW	Memc[II_SAPKW_PTR($1)]
