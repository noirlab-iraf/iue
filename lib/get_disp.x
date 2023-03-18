# Copyright restrictions apply - see iue$doc/copyright.iue

include	<tbset.h>
include	"../mx.h"

#--------------------------------------------------------------------16 Jul 99--
.help get_disp.x Jul99 iue/iuetools
.ih
NAME
.nf
  get_disp - Determine the dispersion mode
.fi
.ih 
Revision History
.nf
   16-Jul-99	RAShaw		Initial version
.fi
.endhelp
#-------------------------------------------------------------------------------
#  GET_DISP -	Get the dispersion type from the table header. Errors out if 
#		disp not HIGH or LOW. 

int procedure get_disp (tp)

# Calling arguments:
pointer	tp		# I: table descriptor

# Declarations:
int	dispersion	# dispersion mode
int	len		# length of header KW value
char	s1[4]		# Generic
int	strdic()	# search a string dictionary
int	strlen()	# compute length of string

errchk	tbhgtt

begin
	call tbhgtt (tp, "EXTNAME", s1, 4)
	call strupr (s1)
	len = strlen (s1)
	dispersion = strdic (s1, s1, len, TB_EXTNAME)
	if (dispersion < 0)
	    call error (1, "Dispersion indeterminate")

	return (dispersion)
end


