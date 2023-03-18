include	<imhdr.h>

#--------------------------------------------------------------------15 May 98--
.help itf_trans.x May98 iuetools/itf_trans
.ih
NAME
  itf_trans - Transpose an ITF reference file from X,Y,Z to Z,X,Y
.ih 
DESCRIPTION
This routine transposes the ITF reference file axis orientation 
from X,Y,Z to Z,X,Y.  The transposed ITF is needed for more efficient 
processing in PHOTOM. 
.endhelp
#-------------------------------------------------------------------------------
#  ITF_TRANS - Transpose an ITF reference file from X,Y,Z to Z,X,Y.

procedure itf_trans() 

# Task parameters:
char	input[SZ_FNAME]		# name of ITF reference file
char	output[SZ_FNAME]	# name of rotated ITF reference file

#  Declarations:
pointer	immap()			# Map an image into memory
pointer	imgs3s(), imps3s()	# get, put image line, TY_SHORT
pointer	in, out			# input, output file descriptor
int	i			# generic
int	np_x, np_y		# no. pixels in X,Y axes
int	npix			# no. pixels in image plane

errchk	immap

begin
	# Open the output image as a copy of the input image.
	call clgstr ("input",  input,  SZ_FNAME)
	call clgstr ("output", output, SZ_FNAME)
	in  = immap (input, READ_ONLY, NULL)
	out = immap (output, NEW_COPY, in)

	# Set the axis attributes for output.
	IM_LEN(out,1) = IM_LEN(in,3)
	IM_LEN(out,2) = IM_LEN(in,1)
	IM_LEN(out,3) = IM_LEN(in,2)
	np_x = IM_LEN(in,1)
	np_y = IM_LEN(in,2)
	npix = np_x * np_y

	# Copy input to output, plane by plane.
	do i = 1, IM_LEN(in,3) 
	    call amovs (Mems[imgs3s (in, 1, np_x, 1, np_y, i, i)], 
			Mems[imps3s (out, i, i, 1, np_x, 1, np_y)], npix)

	# Close the images.
	call imunmap (in)
	call imunmap (out)
end


