# Copyright restrictions apply - see iue$doc/copyright.iue

include	<tbset.h>
include	"../mx.h"

#--------------------------------------------------------------------16 Jul 99--
.help get_colptr.x Jul99 iue/iuetools
.ih
NAME
.nf
  get_colptr - Get pointer to a specified table column
.fi
.ih 
Revision History
.nf
   16-Jul-99	RAShaw		Initial version
.fi
.endhelp
#-------------------------------------------------------------------------------
#  GET_COLPTR -	Get pointer to specified table column.  Errors out if column 
#		not found. 

procedure get_colptr (tp, col_name, cp)

# Calling arguments:
pointer	tp		# I: table descriptor
char	col_name[ARB]	# I: name of column to find
pointer	cp		# O: column pointer

# Declarations:
char	errmsg[SZ_LINE]		# error message string

begin
	# Fetch the various column names & pointers.
	call tbcfnd (tp, col_name, cp, 1)
	if (cp == NULL) {
	    call strcpy ("%s column not found in input table", errmsg, SZ_LINE)
		call pargstr (col_name)
	    call error (1, errmsg)
	}
end


